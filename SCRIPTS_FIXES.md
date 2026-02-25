# Исправления скриптов и конфигурации Meowrch NixOS
**Дата:** 2026-02-25

---

## ✅ Исправленные скрипты

### 1. `dotfiles/bin/system-update.sh` — **критическое исправление**
- **Проблема:** Скрипт проверял `/etc/arch-release` и использовал `pacman`/`checkupdates` — не работает на NixOS
- **Исправление:**
  - Добавлено определение дистрибутива (`is_nixos()`, `is_arch()`)
  - Для NixOS: запускает `nixos-rebuild switch --flake /home/meowrch/NixOS-Meowrch#meowrch`
  - Поддержка терминалов: `kitty`, `foot`, `alacritty`, `wezterm`, `gnome-terminal`, `xterm`
  - Совместимость с Arch Linux сохранена

### 2. `dotfiles/bin/resetxdgportal.sh`
- **Проблема:** Использовал `killall` (не всегда доступен на NixOS), хардкод путей
- **Исправление:** Заменён на `pkill`, динамический поиск бинарников портала в `/run/current-system/sw/libexec`, `/usr/lib`, `/usr/libexec`

### 3. `dotfiles/bin/toggle-hypr-sworkspace.sh`
- **Проблема:** Ненадёжный парсинг через `awk` вывода `hyprctl activeworkspace`
- **Исправление:** Использует `hyprctl -j activewindow | jq` для надёжного JSON-парсинга

### 4. `dotfiles/bin/battery.sh`
- **Проблема:** Fallback путь `${XDG_BIN_HOME:-$HOME/bin}` — неверный (нужен `~/.local/bin`)
- **Исправление:** `${XDG_BIN_HOME:-$HOME/.local/bin}`

### 5. `dotfiles/bin/toggle-bar.sh`
- **Проблема:** То же — неверный fallback `$HOME/bin` в двух местах
- **Исправление:** `$HOME/.local/bin` в обоих местах

### 6. `dotfiles/bin/switch-hypr-bar.sh`
- **Проблема:** То же — неверный fallback `$HOME/bin`
- **Исправление:** `$HOME/.local/bin`

### 7. `dotfiles/bin/rofi-menus/powermenu.sh`
- **Проблема:** Logout не работал для Hyprland (`pkill -KILL -u $USER` убивает всё включая sessid)
- **Исправление:** Корректный `hyprctl dispatch exit` для Hyprland, `loginctl terminate-user` как fallback

### 8. `dotfiles/bin/rofi-menus/wallpaper-selector.sh`
- **Проблема:** Хардкод `magick convert` (только ImageMagick v7), неверный путь `$HOME/bin`
- **Исправление:**
  - Функция `_magick_cmd()` — автоматически выбирает `magick` (v7) или `convert` (v6)
  - Экспорт `_magick_cmd` в параллельный xargs-блок
  - Путь исправлен на `$HOME/.local/bin`

### 9. `dotfiles/bin/rofi-menus/network-manager.sh`
- **Проблема:** `exit 1` вместо `exit 0` после показа статуса; хардкод `wlan0`
- **Исправление:** `exit 0`, динамическое определение WiFi-интерфейса через `nmcli`

### 10. `dotfiles/bin/system-info.py`
- **Проблема:** Жёсткие `import psutil, GPUtil, pyamdgpuinfo` — падает если пакеты не установлены
- **Исправление:**
  - Graceful `try/except` для всех трёх пакетов с флагами `HAS_PSUTIL/HAS_GPUTIL/HAS_PYAMDGPUINFO`
  - Поддержка AMD temp-сенсора `k10temp` наряду с Intel `coretemp`
  - Исправлен парсинг `model name` из `/proc/cpuinfo`

---

## ✅ Исправленные NixOS-конфигурации

### 11. `packages/meowrch-scripts.nix` — **полная переработка**
- **Добавлены зависимости:** `util-linux`(flock), `jq`, `imagemagick`, `curl`, `zenity`, `libnotify`, `bc`, `hyprpicker`, `hyprlock`, `wlr-randr`
- **Python:** `python3.withPackages [psutil pyyaml]` вместо голого `python3`
- **Обёртывание:** `makeWrapper`/`wrapProgram` вместо ненадёжных heredoc-обёрток
- **Покрытие:** top-level `.sh`, `.py`, подпапка `rofi-menus/*.sh`

### 12. `flake.nix`
- **Исправление:** Правильная передача `hyprland.packages.${system}.hyprland` в `meowrch-scripts`

### 13. `home/home.nix`
- **Исправлены пути алиасов:** `meowrch-nixos` → `NixOS-Meowrch` (реальное имя директории) — в `update`, `validate`, `config`, `edit-*`, `cd-*`, `backup-config`
- **Исправлены rebuild-алиасы:** добавлен полный путь `/home/meowrch/NixOS-Meowrch#meowrch` вместо `.#meowrch` (работают из любой директории)
- **Добавлена переменная:** `XDG_BIN_HOME = "$HOME/.local/bin"` — критично для работы скриптов

---

## 📋 Что не изменилось (работает корректно)

- `volume.sh` — OK
- `brightness.sh` — OK  
- `kb-layout.sh` — OK
- `do-not-disturb.sh` — OK
- `screen-lock.sh` — OK
- `set-wallpaper.sh` — OK
- `uwsm-launcher.sh` — OK
- `media.sh` — OK
- `playerinfo.sh` — OK
- `window-close.sh` / `window-kill.sh` / `window-pin.sh` — OK
- `gpu-detect-profile.sh` — OK
- `color-picker.sh` — OK
- `clipboard-manager.sh` — OK
- `vpn-manager.sh` — OK
- `rofimoji.sh` — OK
- `theme-selector.sh` — OK

---

## 🚀 Следующий шаг

```bash
# Пересборка системы
sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch \
  --flake /home/meowrch/NixOS-Meowrch#meowrch --impure
```
