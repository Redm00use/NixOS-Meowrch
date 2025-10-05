#!/usr/bin/env bash
#
# check-macos.sh
#
# Helper script for running NON-BUILD validation of a NixOS flake
# from macOS (or any non-Linux host) without attempting to build
# Linux-only derivations, and with optional remote builder support.
#
# Features:
#   1. Verifies Nix + flake support availability
#   2. Shows flake structure (syntax validation)
#   3. Evaluates NixOS system drvPath (ensures graph is valid)
#   4. Runs `nix flake check` (but allows failure collection)
#   5. Optional: dry-run / best‑effort remote build if a Linux builder is configured
#   6. Provides guidance if evaluation fails due to syntax or missing inputs
#
# Usage:
#   chmod +x scripts/check-macos.sh
#   ./scripts/check-macos.sh
#
# Flags:
#   --flake .                Use a different flake path (default: current directory)
#   --attr meowrch           Override NixOS configuration attribute (default: meowrch)
#   --no-check               Skip `nix flake check`
#   --remote-build           Attempt remote build (requires configured Linux builder)
#   --show-trace             Add --show-trace to evaluation steps
#   --json                   Emit machine-readable JSON summary (basic)
#   --quiet                  Minimal output
#
# Remote builder note:
#   Configure /etc/nix/nix.conf or ~/.config/nix/nix.conf with:
#     builders = ssh-ng://linux-host x86_64-linux - 4 1 kvm,nixos-test,benchmark,big-parallel
#
set -euo pipefail

# ---------------------------- Styling ----------------------------
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
MAG=$'\033[0;35m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'

log()  { [[ -n "${QUIET:-}" ]] || echo -e "${BLUE}[INFO]${RESET} $*"; }
ok()   { [[ -n "${QUIET:-}" ]] || echo -e "${GREEN}[OK]${RESET}   $*"; }
warn() { [[ -n "${QUIET:-}" ]] || echo -e "${YELLOW}[WARN]${RESET} $*"; }
err()  { echo -e "${RED}[ERR]${RESET}  $*" >&2; }

# ------------------------- Defaults / Args -----------------------
FLAKE_PATH="."
ATTR="meowrch"
DO_CHECK=1
REMOTE_BUILD=0
SHOW_TRACE=0
EMIT_JSON=0
QUIET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flake)         FLAKE_PATH="$2"; shift 2 ;;
    --attr)          ATTR="$2"; shift 2 ;;
    --no-check)      DO_CHECK=0; shift ;;
    --remote-build)  REMOTE_BUILD=1; shift ;;
    --show-trace)    SHOW_TRACE=1; shift ;;
    --json)          EMIT_JSON=1; shift ;;
    --quiet)         QUIET=1; shift ;;
    -h|--help)
      cat <<EOF
Usage: $0 [options]

Options:
  --flake PATH          Flake directory (default: .)
  --attr NAME           NixOS configuration attribute (default: meowrch)
  --no-check            Skip 'nix flake check'
  --remote-build        Attempt remote build (requires Linux builder)
  --show-trace          Add --show-trace to eval operations
  --json                Output a small JSON summary at the end
  --quiet               Reduce verbosity
  -h, --help            Show this help

Examples:
  $0
  $0 --flake . --attr meowrch
  $0 --remote-build
EOF
      exit 0
      ;;
    *)
      err "Unknown argument: $1"
      exit 1
      ;;
  esac
done

TRACE_FLAG=""
[[ $SHOW_TRACE -eq 1 ]] && TRACE_FLAG="--show-trace"

START_TS=$(date +%s)
STATUS_FLAKE_SHOW=0
STATUS_DRV_EVAL=0
STATUS_CHECK=0
STATUS_REMOTE_BUILD=0
DRV_PATH=""
SYS_ATTR="#nixosConfigurations.${ATTR}.config.system.build.toplevel"

# ------------------------ Pre-flight checks ----------------------
if [[ ! -d "$FLAKE_PATH" ]]; then
  err "Flake path '$FLAKE_PATH' does not exist"
  exit 1
fi

if [[ ! -f "$FLAKE_PATH/flake.nix" ]]; then
  err "flake.nix not found in '$FLAKE_PATH'"
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  err "Nix is not installed. Install via: sh <(curl -L https://nixos.org/nix/install)"
  exit 1
fi

OS=$(uname -s || true)
if [[ "$OS" != "Darwin" ]]; then
  warn "This helper is intended for macOS host usage; detected $OS."
fi

log "Using flake: ${FLAKE_PATH}"
log "Target NixOS configuration attribute: ${ATTR}"
log "Remote build: $([[ $REMOTE_BUILD -eq 1 ]] && echo enabled || echo disabled)"

# ----------------------- Step 1: flake show ----------------------
log "Step 1: Flake syntax / structure (nix flake show)"
if nix flake show "$FLAKE_PATH" >/dev/null 2>&1; then
  ok "flake show succeeded"
  STATUS_FLAKE_SHOW=0
else
  STATUS_FLAKE_SHOW=1
  err "flake show failed"
fi

# -------------------- Step 2: evaluate drvPath -------------------
log "Step 2: Evaluate system drvPath (no build)"
if DRV_PATH=$(nix eval "$FLAKE_PATH"."$SYS_ATTR".drvPath $TRACE_FLAG 2>/dev/null); then
  ok "drvPath resolved: ${DRV_PATH}"
  STATUS_DRV_EVAL=0
else
  STATUS_DRV_EVAL=1
  err "Failed to evaluate drvPath. Possible causes:"
  echo "  - Attribute name wrong (--attr ${ATTR})"
  echo "  - Syntax error in configuration"
  echo "  - Missing input or unsupported platform logic"
fi

# -------------------- Step 3: flake check ------------------------
if [[ $DO_CHECK -eq 1 ]]; then
  log "Step 3: nix flake check (this may run tests / build small derivations)"
  if nix flake check "$FLAKE_PATH" $TRACE_FLAG; then
    ok "flake check passed"
    STATUS_CHECK=0
  else
    STATUS_CHECK=$?
    warn "flake check reported issues (exit $STATUS_CHECK)"
  fi
else
  warn "Skipped flake check (--no-check)"
  STATUS_CHECK=0
fi

# -------------------- Step 4: remote build (optional) ------------
if [[ $REMOTE_BUILD -eq 1 ]]; then
  log "Step 4: Attempt remote build (requires Linux builder)"
  # We force --builders '' if user forgot, to avoid local attempt on macOS
  # Actually: better to let Nix decide; if no builder, it will fail gracefully
  if nix build "$FLAKE_PATH"."$SYS_ATTR" $TRACE_FLAG; then
    ok "Remote (or cross) build succeeded"
    STATUS_REMOTE_BUILD=0
  else
    STATUS_REMOTE_BUILD=$?
    warn "Remote build failed (expected if no Linux builder configured)"
  fi
else
  log "Step 4: Remote build skipped (--remote-build not set)"
fi

END_TS=$(date +%s)
DURATION=$((END_TS - START_TS))

# ---------------------- Summary (human) --------------------------
if [[ $EMIT_JSON -eq 0 ]]; then
  echo
  echo -e "${BOLD}Summary:${RESET}"
  printf "  flake show          : %s\n"  "$([[ $STATUS_FLAKE_SHOW -eq 0 ]] && echo "${GREEN}OK${RESET}" || echo "${RED}FAIL${RESET}")"
  printf "  drvPath evaluation  : %s\n"  "$([[ $STATUS_DRV_EVAL -eq 0 ]] && echo "${GREEN}OK${RESET}" || echo "${RED}FAIL${RESET}")"
  printf "  flake check         : %s\n"  "$([[ $STATUS_CHECK -eq 0 ]] && echo "${GREEN}OK${RESET}" || echo "${YELLOW}ISSUES${RESET}")"
  printf "  remote build        : %s\n"  "$([[ $REMOTE_BUILD -eq 1 ]] && ([[ $STATUS_REMOTE_BUILD -eq 0 ]] && echo "${GREEN}OK${RESET}" || echo "${YELLOW}FAILED${RESET}") || echo "SKIPPED")"
  printf "  total time          : %ss\n" "$DURATION"
  echo

  if [[ $STATUS_DRV_EVAL -ne 0 ]]; then
    echo -e "${RED}Next steps to debug drvPath:${RESET}"
    echo "  1. Run with --show-trace: nix eval ${FLAKE_PATH}.${SYS_ATTR}.drvPath --show-trace"
    echo "  2. Verify attribute name matches nixosConfigurations.<name>"
    echo "  3. Check for syntax errors: nix fmt (or alejandra) then git diff"
    echo "  4. Run: nix flake metadata ${FLAKE_PATH}"
    echo
  fi

  if [[ $REMOTE_BUILD -eq 1 && $STATUS_REMOTE_BUILD -ne 0 ]]; then
    echo -e "${YELLOW}Remote build failed.${RESET} If you expected success:"
    echo "  - Check 'nix show-config | grep builders'"
    echo "  - Ensure your Linux builder has matching system = x86_64-linux"
    echo "  - Add to ~/.config/nix/nix.conf: builders = ssh-ng://user@host x86_64-linux"
  fi
else
  # ---------------------- JSON Output ---------------------------
  jq -n \
    --arg flake "$FLAKE_PATH" \
    --arg attr "$ATTR" \
    --arg drvPath "${DRV_PATH:-}" \
    --argjson flakeShow $STATUS_FLAKE_SHOW \
    --argjson drvEval $STATUS_DRV_EVAL \
    --argjson flakeCheck $STATUS_CHECK \
    --argjson remoteBuild $STATUS_REMOTE_BUILD \
    --argjson duration $DURATION \
    '{
      flake: $flake,
      attr: $attr,
      drvPath: $drvPath,
      steps: {
        flakeShow: (if $flakeShow==0 then "ok" else "fail" end),
        drvEval: (if $drvEval==0 then "ok" else "fail" end),
        flakeCheck: (if $flakeCheck==0 then "ok" else "issues" end),
        remoteBuild: (if $remoteBuild==0 then "ok" else (if $remoteBuild==1 then "fail" else "skipped" end) end)
      },
      durationSeconds: $duration
    }'
fi

# Exit code policy:
#   Prefer success if drv evaluation works (core guarantee), even if flake check warns
FINAL_EXIT=0
if [[ $STATUS_DRV_EVAL -ne 0 ]]; then
  FINAL_EXIT=2
elif [[ $STATUS_FLAKE_SHOW -ne 0 ]]; then
  FINAL_EXIT=3
fi

exit $FINAL_EXIT
