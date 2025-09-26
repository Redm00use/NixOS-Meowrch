#!/usr/bin/env bash
#
# Meowrch NixOS Advanced Installer
# ===================================================================
# High-level goals:
#   - Zero / minimal manual editing for newcomers.
#   - Multi-user provisioning (primary + optional extra users).
#   - Hardware configuration generation (idempotent).
#   - Safe patching of flake-based configuration (primary user only).
#   - Non-interactive / scriptable (CI friendly).
#   - Rich logging (console + file + optional JSON summary).
#   - Dry-run capability.
#
# THIS FILE WAS AUTO-GENERATED / REWRITTEN BY ASSISTANT ON REQUEST.
# You may adapt freely. It strives to be defensive rather than “smart”.
#
# -------------------------------------------------------------------
# QUICK START (Typical Single User)
# -------------------------------------------------------------------
#   ./install.sh --user meowrch --full-name "Meowrch User" \
#       --email user@example.com --git-name "Meowrch User"
#
# Multi-user:
#   ./install.sh \
#     --user-spec "alice,Alice Liddell,alice@example.org,Alice L." \
#     --user-spec "bob,Bob Builder,bob@example.net,Bob B."
#
# Dry-run (no changes):
#   ./install.sh --user test --dry-run
#
# JSON summary (machine parsing):
#   ./install.sh --user meowrch --json --no-build
#
# Generate (or regenerate) hardware config:
#   ./install.sh --user meowrch --regenerate-hardware
#
# Skip hardware:
#   ./install.sh --user meowrch --no-hardware
#
# Generate an installer-oriented README:
#   ./install.sh --generate-installer-readme --dry-run   # (preview)
#   ./install.sh --generate-installer-readme             # (write file)
#
# -------------------------------------------------------------------
# USER SPEC SYNTAX
#   --user-spec "username[,Full Name[,Email[,Git Name]]]"
#   Fields after username are optional. Commas inside values are NOT supported.
#
#   Examples:
#     --user-spec "alice"
#     --user-spec "alice,Alice Wonderland"
#     --user-spec "alice,Alice Wonderland,alice@host"
#     --user-spec "alice,Alice Wonderland,alice@host,Alice W."
#
# The *first* specified user (either via --user / legacy flags
# or first --user-spec) becomes the PRIMARY USER:
#   - Patched into configuration.nix and home/home.nix
#   - Home Manager profile assumed to exist for that user.
#
# Extra users are created at OS level only (useradd) and NOT added
# into the Nix flake automatically (safer for newcomers).
#
# -------------------------------------------------------------------
# EXIT CODES
#   0 success
#   1 generic error
#   2 invalid usage
#   3 dependency missing
#   4 environment / safety violation
#
# -------------------------------------------------------------------
# LICENSE
#   Use / modify / redistribute freely (public domain style).
#
set -euo pipefail

###############################################################################
# Globals (defaults & mutable state)
###############################################################################
DEFAULT_PRIMARY_USER="meowrch"
DEFAULT_FULL_NAME="Meowrch User"
DEFAULT_EMAIL="user@example.com"
DEFAULT_GIT_NAME=""                # Fallback: FULL NAME
DEFAULT_STATE_VERSION="25.05"
DEFAULT_FLAKE_HOST="meowrch"

# Arrays for multi-user (parallel indices)
USERS=()
FULL_NAMES=()
EMAILS=()
GIT_NAMES=()

PRIMARY_INDEX=0

# Flags / behavior toggles
FLAG_FORCE=false
FLAG_NO_BACKUP=false
FLAG_NO_BUILD=false
FLAG_NO_HOMEMANAGER=false
FLAG_NO_HARDWARE=false
FLAG_REGENERATE_HARDWARE=false
FLAG_DRY_RUN=false
FLAG_JSON=false
FLAG_FAST=false
FLAG_IMPURE=false
FLAG_GENERATE_INSTALLER_README=false
FLAG_QUIET=false
FLAG_LOG_STDERR_SEPARATE=false

# Core config
STATE_VERSION="$DEFAULT_STATE_VERSION"
FLAKE_HOST="$DEFAULT_FLAKE_HOST"
HOST_NAME=""                       # Optional override

# Logging
LOG_DIR=""
LOG_FILE=""
LOG_LINK_RECENT="latest-install.log"
START_TS=$(date +%s)
SUMMARY_MESSAGES=()
ERROR_MESSAGES=()

# Colors (TTY only)
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_RED=$'\033[0;31m'
  C_GRN=$'\033[0;32m'
  C_YEL=$'\033[1;33m'
  C_BLU=$'\033[0;34m'
  C_MAG=$'\033[0;35m'
  C_CYN=$'\033[0;36m'
  C_WHT=$'\033[1;37m'
else
  C_RESET= C_RED= C_GRN= C_YEL= C_BLU= C_MAG= C_CYN= C_WHT=
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Logging Helpers
###############################################################################
_ts() { date +"%Y-%m-%d %H:%M:%S"; }

_log_raw() { echo -e "[$(_ts)] $*"; }

log()     { $FLAG_QUIET || _log_raw "${C_WHT}[LOG]${C_RESET} $*"; }
info()    { $FLAG_QUIET || _log_raw "${C_BLU}[INFO]${C_RESET} $*"; }
success() { $FLAG_QUIET || _log_raw "${C_GRN}[ OK ]${C_RESET} $*"; }
warn()    { _log_raw "${C_YEL}[WARN]${C_RESET} $*"; }
err()     { _log_raw "${C_RED}[ERR ]${C_RESET} $*"; ERROR_MESSAGES+=("$*"); }
headline(){ $FLAG_QUIET || _log_raw "\n${C_MAG}=== $* ===${C_RESET}\n"; }
die()     { err "$1"; exit "${2:-1}"; }
add_summary(){ SUMMARY_MESSAGES+=("$*"); }

###############################################################################
# Usage
###############################################################################
usage() {
  cat <<EOF
Meowrch NixOS Advanced Installer
================================

Primary (single-user) quick example:
  $0 --user meowrch --full-name "Meowrch User" --email user@example.com

Multi-user example:
  $0 \\
    --user-spec "alice,Alice Wonderland,alice@host,Alice W." \\
    --user-spec "bob,Bob Builder,bob@host,Bob B."

User / Identity:
  --user <name>                 (Legacy single user shortcut; first user)
  --full-name "<Full Name>"     (Applies to primary if --user used)
  --email <email>               (Applies to primary if --user used)
  --git-name "<Git Name>"       (Applies to primary if --user used)
  --user-spec "u[,Full Name[,Email[,Git Name]]]"  (Repeatable)
  --hostname <host>             Set/patch system hostname (networking.nix)
  --state-version <ver>         Default: ${DEFAULT_STATE_VERSION}
  --flake-host <attr>           Flake NixOS attr (default: ${DEFAULT_FLAKE_HOST})

Behavior Flags:
  --no-build                    Skip nixos-rebuild switch
  --no-home-manager             Skip home-manager activation
  --no-hardware                 Do not generate hardware-configuration.nix
  --regenerate-hardware         Force regeneration of hardware file
  --no-backup                   Skip backup creation
  --fast                        Skip validation (speed iteration)
  --impure                      Pass --impure to nixos-rebuild
  --dry-run                     Show actions only, no changes
  --json                        Emit JSON summary
  --force                       Bypass NixOS check
  --quiet                       Suppress normal logs (errors still shown)
  --log-file <path>             Custom log file (default: ./logs/install-TS.log)
  --log-dir <dir>               Custom log directory (default: ./logs)
  --generate-installer-readme   Create INSTALLER_README.md with usage guide
  --log-stderr-separate         Log stderr to separate file (adds *.err.log)
  --help                        This help

Examples:
  Dry run multi-user:
    $0 --user-spec "alice,Alice A,alice@a" --user-spec "bob,Bob B,bob@b" --dry-run

  With forced hardware regeneration:
    $0 --user meowrch --regenerate-hardware

Exit Codes:
  0 success, 1 failure, 2 usage, 3 missing deps, 4 unsafe env.

EOF
}

###############################################################################
# Argument Parsing
###############################################################################
parse_args() {
  local a
  while [[ $# -gt 0 ]]; do
    a="$1"
    case "$a" in
      --help|-h) usage; exit 0 ;;
      --force) FLAG_FORCE=true; shift ;;
      --no-backup) FLAG_NO_BACKUP=true; shift ;;
      --no-build) FLAG_NO_BUILD=true; shift ;;
      --no-home-manager) FLAG_NO_HOMEMANAGER=true; shift ;;
      --no-hardware) FLAG_NO_HARDWARE=true; shift ;;
      --regenerate-hardware) FLAG_REGENERATE_HARDWARE=true; shift ;;
      --dry-run) FLAG_DRY_RUN=true; shift ;;
      --json) FLAG_JSON=true; shift ;;
      --fast) FLAG_FAST=true; shift ;;
      --impure) FLAG_IMPURE=true; shift ;;
      --quiet) FLAG_QUIET=true; shift ;;
      --generate-installer-readme) FLAG_GENERATE_INSTALLER_README=true; shift ;;
      --log-stderr-separate) FLAG_LOG_STDERR_SEPARATE=true; shift ;;
      --state-version) STATE_VERSION="$2"; shift 2 ;;
      --flake-host) FLAKE_HOST="$2"; shift 2 ;;
      --hostname) HOST_NAME="$2"; shift 2 ;;
      --log-file) LOG_FILE="$2"; shift 2 ;;
      --log-dir) LOG_DIR="$2"; shift 2 ;;
      # Legacy single-user flags (for primary only)
      --user) legacy_single_user_flag "$2"; shift 2 ;;
      --full-name) LEGACY_FULL_NAME="$2"; shift 2 ;;
      --email) LEGACY_EMAIL="$2"; shift 2 ;;
      --git-name) LEGACY_GIT_NAME="$2"; shift 2 ;;
      # New multi-user spec
      --user-spec) parse_user_spec "$2"; shift 2 ;;
      --) shift; break ;;
      -*)
        die "Unknown option: $a (see --help)" 2
        ;;
      *)
        die "Unexpected positional argument: $a" 2
        ;;
    esac
  done
}

legacy_single_user_flag() {
  # Only apply if USERS empty so far (not mixing arbitrarily)
  if ((${#USERS[@]} == 0)); then
    USERS+=("$1")
    FULL_NAMES+=("${LEGACY_FULL_NAME:-$DEFAULT_FULL_NAME}")
    EMAILS+=("${LEGACY_EMAIL:-$DEFAULT_EMAIL}")
    GIT_NAMES+=("${LEGACY_GIT_NAME:-${LEGACY_FULL_NAME:-$DEFAULT_FULL_NAME}}")
  else
    warn "--user ignored because user-spec entries already exist."
  fi
}

parse_user_spec() {
  local spec="$1"
  # Split by comma into up to 4 fields
  IFS=',' read -r U FN EM GN <<<"$spec"
  if [[ -z "${U:-}" ]]; then
    die "Invalid --user-spec '$spec' (username required)" 2
  fi
  FN="${FN:-$DEFAULT_FULL_NAME}"
  EM="${EM:-$DEFAULT_EMAIL}"
  GN="${GN:-$FN}"
  USERS+=("$U")
  FULL_NAMES+=("$FN")
  EMAILS+=("$EM")
  GIT_NAMES+=("$GN")
}

###############################################################################
# Post-parse normalization
###############################################################################
normalize_inputs() {
  if ((${#USERS[@]} == 0)); then
    # Fallback default single user if none provided
    USERS+=("$DEFAULT_PRIMARY_USER")
    FULL_NAMES+=("$DEFAULT_FULL_NAME")
    EMAILS+=("$DEFAULT_EMAIL")
    GIT_NAMES+=("${DEFAULT_FULL_NAME}")
  else
    # Update legacy fields after all parsing
    if [[ -n "${LEGACY_FULL_NAME:-}" ]]; then
      FULL_NAMES[0]="$LEGACY_FULL_NAME"
    fi
    if [[ -n "${LEGACY_EMAIL:-}" ]]; then
      EMAILS[0]="$LEGACY_EMAIL"
    fi
    if [[ -n "${LEGACY_GIT_NAME:-}" ]]; then
      GIT_NAMES[0]="$LEGACY_GIT_NAME"
    fi
  fi
}

###############################################################################
# Logging Setup
###############################################################################
setup_logging() {
  LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/logs}"
  mkdir -p "$LOG_DIR"
  if [[ -z "$LOG_FILE" ]]; then
    LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
  fi
  # Real logging only if not dry-run or always? We'll log anyway.
  if [[ -f "$LOG_FILE" ]]; then
    warn "Log file already exists: $LOG_FILE (appending)"
  fi

  if $FLAG_LOG_STDERR_SEPARATE; then
    local err_file="${LOG_FILE%.log}.err.log"
    exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$err_file" >&2)
    add_summary "stderr_log=$err_file"
  else
    exec > >(tee -a "$LOG_FILE") 2>&1
  fi

  ln -sf "$(basename "$LOG_FILE")" "$LOG_DIR/$LOG_LINK_RECENT" || true
  add_summary "log_file=$LOG_FILE"
  info "Logging to: $LOG_FILE"
}

###############################################################################
# Safety / Environment Checks
###############################################################################
assert_not_root() {
  if [[ $EUID -eq 0 ]]; then
    die "Do NOT run as root. Use normal user with sudo." 4
  fi
}

check_deps() {
  local deps=(git nix sed grep awk cut tr head stat uname rsync)
  local miss=()
  for d in "${deps[@]}"; do
    command -v "$d" >/dev/null 2>&1 || miss+=("$d")
  done
  if ((${#miss[@]})); then
    die "Missing dependencies: ${miss[*]}" 3
  fi
}

check_nixos() {
  if [[ ! -f /etc/NIXOS ]]; then
    if ! $FLAG_FORCE; then
      die "This does not appear to be NixOS (override with --force)" 4
    else
      warn "Proceeding outside NixOS (--force)"
    fi
  else
    success "Detected NixOS"
  fi
}

###############################################################################
# Backup
###############################################################################
perform_backup() {
  if $FLAG_NO_BACKUP; then
    info "Skipping backup (--no-backup)"
    return
  fi
  local ts backup_dir
  ts="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$SCRIPT_DIR/backup-$ts"
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would create backup at $backup_dir"
    return
  fi
  mkdir -p "$backup_dir"
  if [[ -d /etc/nixos ]]; then
    sudo cp -a /etc/nixos "$backup_dir/" 2>/dev/null || true
  fi
  success "Backup created: $backup_dir"
  add_summary "backup_dir=$backup_dir"
}

###############################################################################
# Hardware Config
###############################################################################
generate_hardware_config() {
  local file="$SCRIPT_DIR/hardware-configuration.nix"
  if $FLAG_NO_HARDWARE; then
    info "Skipping hardware config (--no-hardware)"
    return
  fi
  if [[ -f "$file" ]] && ! $FLAG_REGENERATE_HARDWARE; then
    info "Hardware config exists (use --regenerate-hardware to replace)"
    return
  fi
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would generate hardware-configuration.nix"
    return
  fi
  if ! command -v nixos-generate-config >/dev/null 2>&1; then
    warn "nixos-generate-config not found; skipping hardware generation"
    return
  fi
  info "Generating hardware-configuration.nix..."
  if sudo nixos-generate-config --show-hardware-config > "${file}.tmp"; then
    mv "${file}.tmp" "$file"
    success "Hardware configuration written."
    add_summary "hardware_config=generated"
  else
    err "Failed to generate hardware configuration."
    rm -f "${file}.tmp" || true
  fi
}

###############################################################################
# Patch Helpers
###############################################################################
safe_sed() {
  local file="$1" pattern="$2" repl="$3"
  [[ -f "$file" ]] || return 0
  if grep -Eq "$pattern" "$file"; then
    if $FLAG_DRY_RUN; then
      info "(dry-run) $file: s/$pattern/$repl/g"
    else
      sed -i -E "s|$pattern|$repl|g" "$file"
    fi
  fi
}

patch_primary_user_config() {
  local primary_user="${USERS[$PRIMARY_INDEX]}"
  local primary_full="${FULL_NAMES[$PRIMARY_INDEX]}"
  local primary_email="${EMAILS[$PRIMARY_INDEX]}"
  local primary_git="${GIT_NAMES[$PRIMARY_INDEX]}"

  local config_file="$SCRIPT_DIR/configuration.nix"
  local home_file="$SCRIPT_DIR/home/home.nix"
  local net_file="$SCRIPT_DIR/modules/system/networking.nix"

  info "Patching primary user: $primary_user"

  if [[ -f "$config_file" ]]; then
    safe_sed "$config_file" 'users\.meowrch' "users.${primary_user}"
    safe_sed "$config_file" 'system\.stateVersion = "[0-9]+\.[0-9]+"' \
      "system.stateVersion = \"${STATE_VERSION}\""
  fi

  if [[ -f "$home_file" ]]; then
    safe_sed "$home_file" 'home\.username = "[^"]+"' "home.username = \"${primary_user}\""
    safe_sed "$home_file" 'home\.homeDirectory = "/home/[^"]+"' \
      "home.homeDirectory = \"/home/${primary_user}\""
    safe_sed "$home_file" 'home\.stateVersion = "[0-9]+\.[0-9]+"' \
      "home.stateVersion = \"${STATE_VERSION}\""
    # Git identity
    safe_sed "$home_file" 'userName = "[^"]+"' "userName = \"${primary_git}\""
    safe_sed "$home_file" 'userEmail = "[^"]+"' "userEmail = \"${primary_email}\""
    # Path alias normalization
    safe_sed "$home_file" '/home/meowrch/NixOS-25\.05' "/home/${primary_user}/meowrch-nixos"
    safe_sed "$home_file" '/home/meowrch/config-backups' "/home/${primary_user}/config-backups"
    safe_sed "$home_file" '\.#meowrch' ".#${FLAKE_HOST}"
  fi

  if [[ -n "$HOST_NAME" && -f "$net_file" ]]; then
    safe_sed "$net_file" 'hostName = "[^"]+"' "hostName = \"${HOST_NAME}\""
  fi
}

###############################################################################
# Git
###############################################################################
ensure_git_repo() {
  if [[ -d "$SCRIPT_DIR/.git" ]]; then
    info "Git repository detected."
    return
  fi
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would init git repo"
    return
  fi
  ( cd "$SCRIPT_DIR" && git init && git add . && git commit -m "Initial commit (installer)" )
  success "Initialized git repository."
}

commit_changes() {
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would commit changes"
    return
  fi
  if [[ -d "$SCRIPT_DIR/.git" ]]; then
    (
      cd "$SCRIPT_DIR"
      if ! git diff --quiet || ! git diff --cached --quiet; then
        git add .
        git commit -m "Installer patch for primary user ${USERS[$PRIMARY_INDEX]}"
        success "Committed configuration changes."
      else
        info "No configuration changes to commit."
      fi
    )
  fi
}

###############################################################################
# User Provisioning
###############################################################################
ensure_user_exists() {
  local user="$1" full="$2"
  if id "$user" >/dev/null 2>&1; then
    info "User '$user' already exists."
    return
  fi
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would create user: $user"
    return
  fi
  info "Creating user: $user"
  # Use fish if present, fallback otherwise
  local shell="/run/current-system/sw/bin/fish"
  [[ -x "$shell" ]] || shell="/bin/bash"
  sudo useradd -m -c "$full" -G wheel,networkmanager,audio,video,storage,optical,bluetooth -s "$shell" "$user" || {
    warn "Useradd failed for $user"
  }
  add_summary "created_user=$user"
}

provision_all_users() {
  for i in "${!USERS[@]}"; do
    ensure_user_exists "${USERS[$i]}" "${FULL_NAMES[$i]}"
  done
}

###############################################################################
# Deployment of Repository to Primary User
###############################################################################
deploy_repo_to_primary_home() {
  local primary="${USERS[$PRIMARY_INDEX]}"
  local dest="/home/${primary}/meowrch-nixos"
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would sync repo to $dest"
    return
  fi
  sudo mkdir -p "$dest"
  sudo rsync -a --delete --exclude ".git" "$SCRIPT_DIR/" "$dest/"
  sudo chown -R "${primary}:${primary}" "$dest"
  success "Configuration deployed to $dest"
  add_summary "primary_repo=$dest"
}

###############################################################################
# Validation (optional)
###############################################################################
run_validation() {
  if $FLAG_FAST; then
    info "Skipping validation (--fast)"
    return
  fi
  local script="$SCRIPT_DIR/validate-config.sh"
  if [[ ! -x "$script" ]]; then
    info "No validate-config.sh present (skipping validation)"
    return
  fi
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would execute validate-config.sh"
    return
  fi
  info "Running validation..."
  if "$script"; then
    success "Validation passed."
  else
    warn "Validation failed (continuing)."
  fi
}

###############################################################################
# Build / Switch
###############################################################################
build_system() {
  if $FLAG_NO_BUILD; then
    info "Skipping system build (--no-build)"
    return
  fi
  local cmd=(sudo nixos-rebuild switch --flake "$SCRIPT_DIR#${FLAKE_HOST}")
  $FLAG_IMPURE && cmd+=(--impure)
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would run: ${cmd[*]}"
    return
  fi
  info "Building & switching system (flake: $FLAKE_HOST)..."
  if NIXPKGS_ALLOW_UNFREE=1 "${cmd[@]}"; then
    success "System build & switch complete."
  else
    err "System build failed."
  fi
}

###############################################################################
# Home Manager
###############################################################################
apply_home_manager() {
  if $FLAG_NO_HOMEMANAGER; then
    info "Skipping Home Manager (--no-home-manager)"
    return
  fi
  local primary="${USERS[$PRIMARY_INDEX]}"
  if ! command -v home-manager >/dev/null 2>&1; then
    warn "home-manager not in PATH (skipping)."
    return
  fi
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would apply home-manager for $primary"
    return
  fi
  info "Applying Home Manager for $primary"
  if sudo -u "$primary" home-manager switch --flake "$SCRIPT_DIR#${primary}"; then
    success "Home Manager applied."
  else
    warn "Home Manager apply failed."
  fi
}

###############################################################################
# Installer-specific README
###############################################################################
generate_installer_readme() {
  local file="$SCRIPT_DIR/INSTALLER_README.md"
  if $FLAG_DRY_RUN; then
    info "(dry-run) Would generate $file"
    return
  fi
  cat > "$file" <<'EOF'
# Meowrch NixOS Installer Guide

This document was generated by `install.sh --generate-installer-readme`.

## Goals
- Simplify onboarding for people new to Nix / NixOS.
- Automate user + config patching + hardware generation.
- Provide reproducible, idempotent flows.

## Basic Single-User Install
```
./install.sh --user meowrch --full-name "Meowrch User" --email user@example.com
```

## Multi-User
```
./install.sh \
  --user-spec "alice,Alice Wonderland,alice@example.org,Alice W." \
  --user-spec "bob,Bob Builder,bob@example.net,Bob B."
```

The first user becomes the "primary user" whose name is patched into:
- configuration.nix (`users.<name>`)
- home/home.nix
- path aliases and flake references

Other users are created at OS level only (not yet integrated into flake).

## Common Flags
| Flag | Purpose |
|------|---------|
| --dry-run | Preview actions only |
| --no-build | Skip nixos-rebuild switch |
| --no-home-manager | Skip Home Manager apply |
| --no-hardware | Do not generate hardware-configuration.nix |
| --regenerate-hardware | Force regenerate hardware file |
| --fast | Skip validation |
| --json | JSON summary output |
| --log-file path | Custom log file |
| --log-dir dir | Custom log directory |
| --hostname myhost | Patch system hostname |
| --flake-host attr | Flake system attr (default: meowrch) |
| --state-version X.YY | Set system.stateVersion and home.stateVersion |
| --impure | Pass --impure to nixos-rebuild |
| --generate-installer-readme | Regenerate this file |

## Hardware Config
If `hardware-configuration.nix` is absent, it is generated automatically (unless you use `--no-hardware`).

## Validation
If `validate-config.sh` exists and is executable, it runs unless `--fast` is passed.

## Logs
Logs are stored under `./logs/` by default. The latest run is symlinked to `latest-install.log`.

## After Installation
1. Set password (if new user): `sudo passwd <primary-user>`
2. Reboot: `sudo reboot`
3. Explore config: `/home/<primary-user>/meowrch-nixos`
4. Rebuild: `rebuild` alias (if defined in environment)
5. Home Manager apply: `home` alias (if defined)

## Troubleshooting
- Use `--dry-run` to inspect what would change.
- Re-run with `--regenerate-hardware` if disk layout changed.
- If system build fails, run manually:
  ```
  sudo nixos-rebuild switch --flake .#meowrch
  ```
- For verbose logging, omit `--quiet` and check `logs/*.log`.

Happy hacking 🐾
EOF
  success "Generated: $file"
  add_summary "installer_readme=$file"
}

###############################################################################
# Summary / JSON
###############################################################################
print_summary() {
  local elapsed=$(( $(date +%s) - START_TS ))
  local primary="${USERS[$PRIMARY_INDEX]}"

  if $FLAG_JSON; then
    json_escape() { sed 's/\\/\\\\/g; s/"/\\"/g' <<<"$1"; }
    echo "{"
    echo "  \"primary_user\": \"$(json_escape "$primary")\","
    echo "  \"users\": ["
    local i
    for i in "${!USERS[@]}"; do
      [[ $i -ne 0 ]] && echo "    ,"
      echo "    {"
      echo "      \"username\": \"$(json_escape "${USERS[$i]}")\","
      echo "      \"full_name\": \"$(json_escape "${FULL_NAMES[$i]}")\","
      echo "      \"email\": \"$(json_escape "${EMAILS[$i]}")\","
      echo "      \"git_name\": \"$(json_escape "${GIT_NAMES[$i]}")\""
      echo "    }"
    done
    echo "  ],"
    echo "  \"flake_host\": \"$(json_escape "$FLAKE_HOST")\","
    echo "  \"hostname\": \"$(json_escape "${HOST_NAME:-}" )\","
    echo "  \"state_version\": \"$(json_escape "$STATE_VERSION")\","
    echo "  \"dry_run\": $($FLAG_DRY_RUN && echo true || echo false),"
    echo "  \"elapsed_seconds\": $elapsed,"
    echo "  \"summary\": ["
    local first=1
    for m in "${SUMMARY_MESSAGES[@]}"; do
      if (( first )); then first=0; else echo ","; fi
      printf '    "%s"' "$(json_escape "$m")"
    done
    echo
    echo "  ],"
    echo "  \"errors\": ["
    first=1
    for m in "${ERROR_MESSAGES[@]}"; do
      if (( first )); then first=0; else echo ","; fi
      printf '    "%s"' "$(json_escape "$m")"
    done
    echo
    echo "  ]"
    echo "}"
    return
  fi

  headline "Installation Summary"
  echo " Primary user    : $primary"
  echo " Flake host attr : $FLAKE_HOST"
  echo " Hostname patched: ${HOST_NAME:-<unchanged>}"
  echo " State version   : $STATE_VERSION"
  echo " Users processed : ${#USERS[@]}"
  echo " Hardware file   : $($FLAG_NO_HARDWARE && echo 'skipped' || $FLAG_REGENERATE_HARDWARE && echo 'regenerated' || echo 'generated/kept')"
  echo " System build    : $($FLAG_NO_BUILD && echo 'skipped' || echo 'attempted')"
  echo " Home Manager    : $($FLAG_NO_HOMEMANAGER && echo 'skipped' || echo 'attempted')"
  echo " Dry run         : $($FLAG_DRY_RUN && echo yes || echo no)"
  echo " Log file        : $LOG_FILE"
  echo " Duration (s)    : $elapsed"
  if ((${#SUMMARY_MESSAGES[@]})); then
    echo
    echo " Actions:"
    for m in "${SUMMARY_MESSAGES[@]}"; do
      echo "   - $m"
    done
  fi
  if ((${#ERROR_MESSAGES[@]})); then
    echo
    echo -e "${C_RED}Errors:${C_RESET}"
    for m in "${ERROR_MESSAGES[@]}"; do
      echo "   - $m"
    done
  fi
  echo
  if ! $FLAG_DRY_RUN; then
    echo "Next steps:"
    echo "  sudo passwd $primary"
    echo "  sudo reboot"
    echo "  cd /home/$primary/meowrch-nixos"
  fi
  echo
}

###############################################################################
# Main
###############################################################################
main() {
  parse_args "$@"
  normalize_inputs
  setup_logging
  assert_not_root
  check_deps
  check_nixos

  headline "Meowrch NixOS Advanced Installer"
  info "Primary user: ${USERS[$PRIMARY_INDEX]} (total users: ${#USERS[@]})"
  info "Flake host: $FLAKE_HOST | StateVersion: $STATE_VERSION"
  $FLAG_DRY_RUN && warn "DRY RUN MODE: no changes will be written."

  perform_backup
  generate_hardware_config
  patch_primary_user_config
  ensure_git_repo
  commit_changes
  provision_all_users
  deploy_repo_to_primary_home
  run_validation
  build_system
  apply_home_manager

  if $FLAG_GENERATE_INSTALLER_README; then
    generate_installer_readme
  fi

  print_summary
}

###############################################################################
# Trap & Invoke
###############################################################################
trap 'err "Script interrupted or failed (exit code $?)"' ERR
main "$@"
