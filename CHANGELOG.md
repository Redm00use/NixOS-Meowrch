# Changelog

All notable changes to this project will be documented in this file.

The format loosely follows:
- Keep a Changelog principles
- Semantic-style version headers (date in ISO format)
- Sections omitted if no entries

---

## [2.0.0] - 2025-09-27

### Overview
Major cleanup and generalization release focused on:
- Полная отвязка от жёстко прошитого имени пользователя
- Упрощение flake-конфигурации
- Удаление автоконфигурации Git и email
- Подготовка проекта к массовому использованию и форкам

### Added
- Interactive primary user prompt in `install.sh` (если не указан `--user`)
- Automatic flake patching when username differs from the default
- Deployment of repository into `/home/<user>/meowrch-nixos` via installer
- Consistent backup + logging + JSON summary framework in installer
- Dev shell (`nix develop`) with formatting tools (alejandra, nixd, nil)

### Changed
- `flake.nix` drastically simplified (удалены большие блоки комментариев и примеры)
- Overlays now applied through a concise module injection pattern
- Cleaner `devShell` output (reduced verbosity)
- Documentation (RU/EN) updated to reflect removal of Git/email automation
- Alias documentation generalized (`.#USERNAME` instead of specific name)
- Removed Docker and Waydroid enablement from default configuration (commented out)

### Removed
- Git identity configuration (`programs.git`) from Home Manager configs
- Email prompts and automatic patching in `install.sh`
- References to deprecated `change-user.sh` workflow
- Excess explanatory comments / tutorial scaffold in `flake.nix`
- Hardcoded paths with legacy directory names (normalized to `meowrch-nixos`)

### Fixed
- Potential inconsistency when switching primary user after initial install
- Redundant enabling of `udisks2` across modules (logic consolidated)
- Reduced risk of leaving stale username references in aliases and paths

### Security / Hardening Notes
- Retained existing security module structure (polkit rules, kernel sysctl)
- Ensured installer refuses to run as root (enforces normal user + sudo)
- Backups of prior `/etc/nixos` (if present) before patching

### Migration Notes (1.x → 2.0)
| Area | Action |
|------|--------|
| Username change | Now handled by `install.sh` interactive prompt or manual flake edit |
| Git config | Configure manually: `git config --global user.name ...` |
| Email removal | No longer stored; user sets manually per repo |
| Old aliases referencing `meowrch` | Regenerate environment by re-running Home Manager |
| Waydroid / Docker | Re-enable manually in `configuration.nix` if required |
| `change-user.sh` | Fully deprecated—delete if present in forks |

### Recommended Post-Update Steps
```bash
# Pull latest changes
git pull

# (Optional) Re-run installer to patch username if you forked earlier:
./install.sh --user <yourname> --no-build --dry-run   # preview
./install.sh --user <yourname>

# Apply system build
sudo nixos-rebuild switch --flake .#meowrch

# Apply Home Manager profile (if using)
home-manager switch --flake .#<yourname>
```

### Known Limitations
- No automatic generation of per-user Git config
- Flake still uses a single `nixosConfigurations.meowrch` attribute (rename manually if desired)
- No GPU vendor profile switching logic yet (AMD-optimized defaults remain)

---

## [1.x] - (Unversioned Historical Phase)
Untracked iteration phase with:
- Initial Hyprland + Catppuccin theming
- Early combined system + user configuration
- Hardcoded user (`meowrch` / `redm00us`)
- Preliminary installer groundwork

---

## Future (Planned / Ideas)
- Optional profiles: `minimal`, `gaming`, `dev`, `nvidia`
- CI pipeline: `nix flake check` + VM boot smoke test
- Module for selective feature toggles (Steam / Spicetify / Theming)
- Declarative secrets integration (sops-nix or agenix)
- Hardware profile auto-detection prompts

---

## Versioning Policy
- Major: structural or onboarding-impacting changes
- Minor: feature additions without breaking defaults
- Patch: documentation & small correctness adjustments

---

## Attribution
Originally based on a themed rice concept; evolved for broader reproducibility and extensibility.

---

[2.0.0]: https://github.com/Redm00use/NixOS-Meowrch/commit/3840965