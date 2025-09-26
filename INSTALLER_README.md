# Meowrch NixOS Advanced Installer Guide

This document explains how to use the `install.sh` advanced installer included in this repository.  
It is designed for both absolute beginners to NixOS and experienced users who want a fast, reproducible bootstrap workflow.

---

## Table of Contents
1. What This Installer Does
2. Quick Start (Single User)
3. Multi-User Mode
4. Core Concepts
5. Hardware Configuration Handling
6. Command Reference (Flags)
7. Examples
8. Logging & Output
9. File / Repo Structure
10. Typical Workflow Scenarios
11. Validation Phase
12. Dry Run Mode
13. JSON Output Mode
14. Security & Safety Notes
15. Troubleshooting
16. FAQ
17. Glossary
18. Contributing
19. License / Reuse

---

## 1. What This Installer Does

The installer automates:
- Creating (or reusing) one **primary user** and optional additional users.
- Patching `configuration.nix` and `home/home.nix` to reflect the chosen primary user.
- Normalizing hardcoded paths inside your Home Manager config.
- (Optionally) generating `hardware-configuration.nix` if it does not exist.
- Running validation (if a `validate-config.sh` script exists).
- Building and switching the NixOS system (`nixos-rebuild`).
- Applying Home Manager for the primary user.
- Initializing a Git repository (if missing) and committing automated changes.
- Producing rich logs and optional JSON summary.
- Supporting fully non-interactive, idempotent runs.

The installer never silently overwrites your already versioned changes without committing (it commits after patching if Git is present).

---

## 2. Quick Start (Single User)

Basic full installation with a single (primary) user:

    ./install.sh --user meowrch \
      --full-name "Meowrch User" \
      --email user@example.com \
      --git-name "Meowrch User"

After it completes:

    sudo passwd meowrch
    sudo reboot

Your working configuration copy is in:

    /home/meowrch/meowrch-nixos

---

## 3. Multi-User Mode

You can provision multiple system users in one invocation. The first listed user becomes the **primary** (the one patched into Nix files and given a Home Manager profile). Others are system-level only (they are *not* automatically added to the flake).

Syntax for multi-user:

    ./install.sh \
      --user-spec "alice,Alice Wonderland,alice@host,Alice W." \
      --user-spec "bob,Bob Builder,bob@host,Bob B."

Each --user-spec field format:
    username[,Full Name[,Email[,Git Name]]]

Examples:
- Only username:  --user-spec "alice"
- Username + full name:  --user-spec "alice,Alice A."
- Username + full + email:  --user-spec "alice,Alice A.,alice@host"
- Full form:  --user-spec "alice,Alice A.,alice@host,Alice Author"

Legacy single-user flags (--user, --full-name, --email, --git-name) still work. If you mix them with --user-spec, the first user-spec defines the primary user (legacy flags apply only if no user-spec is given).

---

## 4. Core Concepts

Primary user:
- Appears in `users.<name>` inside `configuration.nix`.
- Home Manager config patched in `home/home.nix`.
- Path and alias rewrites target this user.
- Gets repository copy in `/home/<user>/meowrch-nixos`.
- Optionally has Home Manager activated.

Additional users:
- Created via useradd with standard groups (wheel, networkmanager, audio, video, etc.).
- No automatic flake integration (you can add them manually later if desired).

Idempotency:
- Running the installer multiple times with the same inputs should not break your environment.
- Only differences are re-committed if changes occur.

---

## 5. Hardware Configuration Handling

The file `hardware-configuration.nix`:
- Generated if missing (unless you pass `--no-hardware`).
- Regenerated forcibly if you pass `--regenerate-hardware`.
- Ignored by Git if you have it in `.gitignore` (recommended for portability).
- If you move disks or change partition layout, re-run with `--regenerate-hardware`.

---

## 6. Command Reference (Flags)

User / identity:
- --user NAME                  (Primary user shortcut)
- --full-name "Full Name"      (Primary only with --user)
- --email EMAIL                (Primary only with --user)
- --git-name "Git Author"      (Primary only with --user)
- --user-spec "u[,Full[,Email[,Git]]]"  (Repeatable multi-user definition)
- --hostname HOST              Patch hostname in networking module
- --state-version X.YY         Override system.stateVersion & home.stateVersion (default 25.05)
- --flake-host ATTR            Flake attribute for the system (default: meowrch)

Behavior:
- --no-build                   Skip nixos-rebuild
- --no-home-manager            Skip Home Manager activation
- --no-hardware                Do not create hardware-configuration.nix
- --regenerate-hardware        Force regenerate hardware file
- --no-backup                  Skip backup of /etc/nixos and ~/.config
- --fast                       Skip validation script phase
- --impure                     Append --impure to nixos-rebuild command
- --dry-run                    Show actions only; no file changes or system operations
- --json                       Emit JSON summary at the end
- --quiet                      Suppress most logging (errors still printed)
- --log-file PATH              Explicit log file path
- --log-dir DIR                Directory for logs (default: ./logs)
- --log-stderr-separate        Separate stderr log file
- --generate-installer-readme  Generate (or update) INSTALLER_README.md
- --force                      Proceed even if not on NixOS
- --help                       Show usage

---

## 7. Examples

Single user minimal:

    ./install.sh --user demo

Multi-user with explicit metadata:

    ./install.sh \
      --user-spec "dev,Dev User,dev@example.org,Dev U." \
      --user-spec "ops,Ops Engineer,ops@example.org,Ops Team"

Regenerate hardware file and rebuild:

    ./install.sh --user meowrch --regenerate-hardware

Skip build & home-manager (prepare only):

    ./install.sh --user meowrch --no-build --no-home-manager

Dry run (preview):

    ./install.sh --user meowrch --dry-run

JSON output (machine consumption):

    ./install.sh --user meowrch --json --no-build

Quiet logging with custom log directory:

    ./install.sh --user meowrch --quiet --log-dir /tmp/m-logs

Generate installer README only:

    ./install.sh --generate-installer-readme --dry-run
    ./install.sh --generate-installer-readme

---

## 8. Logging & Output

- Logs stored under logs/ by default (auto-created).
- A symlink latest-install.log points to the most recent run.
- Use --log-file /path/to/file.log to override name completely.
- Use --log-stderr-separate to capture stderr separately (useful for CI parsing).
- JSON output does not suppress normal logs unless combined with --quiet.

---

## 9. File / Repo Structure (Relevant Parts)

    install.sh                 The advanced installer script
    configuration.nix          Base system config (patched for primary user)
    home/home.nix              Home Manager config (patched)
    modules/system/...         System modules (networking, security, etc.)
    overlays/                  Optional overlay logic
    packages/                  Custom package derivations
    flake.nix / flake.lock     Flake definition

You may add `hosts/<name>/` if you later want multiple system profiles; adjust `--flake-host` accordingly.

---

## 10. Typical Workflow Scenarios

1. Fresh machine (live ISO):
   - Partition + mount target system (standard NixOS workflow).
   - Clone repo into /mnt/root or use a scratch area.
   - Chroot or use NixOS install environment.
   - Run installer with desired user + flags.
   - Reboot into configured system.

2. Add second user later:
   - Run installer again with added --user-spec lines.
   - Or manually add them in `configuration.nix` for fully declarative management.

3. Evolving system config:
   - Edit modules / flake / home.
   - Run: nixos-rebuild switch --flake .#meowrch
   - Or just re-run installer (it will detect and commit new modifications if patching occurs).

4. Changing hostname:
   - ./install.sh --user meowrch --hostname new-host
   - Reboot or restart relevant services if needed.

---

## 11. Validation Phase

If a file named validate-config.sh exists at repo root and is executable:
- It runs unless you pass --fast.
- Non-zero exit DOES NOT abort the whole process (by design for learning). You can harden later.

---

## 12. Dry Run Mode

--dry-run ensures:
- No files are modified.
- No users are created.
- No Nix builds, no hardware config, no commits happen.
- Shows which replacements would occur (path, user naming, etc.).

Use it before major changes or on untrusted environments.

---

## 13. JSON Output Mode

With --json:
- A final JSON object is printed to stdout summarizing:
  - Users processed
  - Primary user
  - Build / hardware flags
  - Duration
  - Summary actions
  - Errors (if any)
- Combine with --quiet to minimize noise for machine integration.

---

## 14. Security & Safety Notes

- Do not run as root. The script enforces this.
- Created users get membership in wheel and other common interactive groups (audit this if hardening).
- hardware-configuration.nix is host-specific; avoid committing it for portability.
- Always review changes in Git to understand patch impact before pushing publicly.
- Do not embed secrets inside Nix configs addressed by this script.

---

## 15. Troubleshooting

Issue: "Missing dependencies"
- Ensure Git & Nix are installed (on a live ISO they are usually present).

Issue: "System build failed"
- Run manually:
      sudo nixos-rebuild switch --flake .#meowrch
- Focus on the first error in the logs.

Issue: "Home Manager not found"
- Confirm it is included in flake inputs and properly imported.

Issue: "hardware-configuration.nix wrong"
- Regenerate with:  ./install.sh --regenerate-hardware --user meowrch

Issue: "User already exists"
- This is fine; the script will reuse it.

---

## 16. FAQ

Q: Can I change the primary user later?
A: Yes. Re-run with new `--user` (or first --user-spec). It will patch config and redeploy.

Q: How do I add more Home Manager users?
A: Manually extend flake.nix or replicate modules; current automation only patches the primary user.

Q: Where are logs?
A: ./logs/ by default (or the directory you specified via --log-dir).

Q: Do I need to update system.stateVersion each release?
A: No. That value should stay the version from your initial base install for compatibility.

Q: Is --impure required?
A: Only if you rely on impure evaluation (normally not necessary unless custom logic demands it).

---

## 17. Glossary

Primary User:
  The first user the installer patches into flake + HM config.

Idempotent:
  Repeated runs do not produce inconsistent state.

hardware-configuration.nix:
  Auto-generated file describing detected disks, file systems, kernel modules.

Flake:
  A Nix packaging system feature enabling reproducible inputs and outputs.

---

## 18. Contributing

Suggested improvements:
- Add host profiles (hosts/<name>.nix).
- Add per-user Home Manager integration automatically.
- Integrate secrets management (SOPS / agenix) – not included yet.
- Improve validation script (lint + dead option checks).

Workflow for changes:
1. Branch
2. Modify modules / installer
3. Run: ./install.sh --dry-run --json (optional)
4. Commit & push

---

## 19. License / Reuse

Unless otherwise stated in a LICENSE file, treat this installer logic as permissive (public domain style).  
Attribution is welcome but not required. Share improvements upstream if useful to others.

---

## Final Notes

You can safely experiment: the dry-run and logging support are there to help you understand what will happen before committing to changes. This repository is a learning-friendly foundation—expand it towards full declarative infra control as you grow more comfortable with NixOS.

Happy building 🐾