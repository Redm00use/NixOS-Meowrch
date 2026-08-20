# Паритет с оригинальным meowrch

| | |
|---|---|
| **Целевая версия upstream** | `4.1.1` |
| **Upstream commit** | `e8ccd122637d14fc456fa8e2d8d05637d0416f30` |
| **Дата релиза upstream** | 19.07.2026 |
| **Источник истины по пакетам** | `meowrch/meowrch` → `Builder/packages.py` |

---

## Что изменилось в upstream между 3.x и 4.1.1

Это **не патч-обновление**. В 4.0.0 upstream сменил архитектуру, и структура
репозитория стала другой:

| Было (3.x) | Стало (4.1.1) |
|---|---|
| `install.py` в корне | `Builder/` — пакет установщика (`install.py`, `question.py`, `managers/`, `utils/`) |
| дотфайлы вразнобой | `home/` — дерево, разворачиваемое как `$HOME` |
| темы внутри репозитория | `misc/` — grub/sddm/plymouth как git-сабмодули |
| — | `VERSION` в корне |
| `install.sh` — большой | `install.sh` — тонкий bootstrap (3.3 КБ) |

**Самое важное для порта:** конфигурация Hyprland переехала с `.conf` на **Lua**.
Теперь это `home/.config/hypr/hyprland.lua` + `home/.config/hypr/default/*.lua`
с декларативным API (`hl.env`, `hl.bind`, `hl.config`, `hl.window_rule`, `hl.on`).

---

## Дельта 4.1.x (мелкие, но заметные изменения)

- `pavucontrol` → **`pwvucontrol`** (нативный для PipeWire)
- добавлен плагин **`nemo-compare`**
- добавлена переменная окружения **`HYPRCURSOR_SIZE`**
- **satty** (редактор скриншотов) теперь плавающее окно
- pawlette-плагин: перезапуск **swaync** при смене темы
- pawlette-плагин: тема иконок **Tela-circle-dracula**
- hot-reload темы в редакторе **micro**
- исправления `hyprlock.conf` (upstream PR #78)
- исправлено размытие скриншота в bspwm
- правки темы VS Code (цвета фона, подсветка текста, цвет текста кнопок GTK)
- редизайн шаблона темы telegram-desktop
- фикс таймаута применения темы в swaync

---

## Статус портирования

### ✅ Сделано в этом PR

| Компонент | Файл | Примечание |
|---|---|---|
| Версия проекта | `VERSION` | `4.1.1` |
| Конфиг Hyprland | `modules/home/hyprland.nix` | Перенос `hypr/*.lua` в `wayland.windowManager.hyprland.settings` |
| X11-сессия (система) | `modules/nixos/desktop/bspwm.nix` | bspwm + sxhkd + X-сервер, раскладка `us,ru` |
| X11-сессия (юзер) | `modules/home/bspwm.nix` | Хоткеи 1:1 из `sxhkdrc`, picom, polybar |
| Паритет пакетов | `modules/nixos/packages/upstream-4.1.1.nix` | Все группы из `Builder/packages.py` |

### ⏳ Осталось (следующие итерации)

| Компонент | Что нужно |
|---|---|
| `awww` / `awww-daemon` | Нет в nixpkgs — нужен собственный пакет в `pkgs/` (заменяет `swww`) |
| `waybar` | Перенести конфиг и стили из `home/.config/waybar` |
| `swaync` | Перенести конфиг и стили из `home/.config/swaync` |
| `polybar` | Перенести `config.ini.pawlette` (9.5 КБ) в Nix |
| `mewline` | Сверить конфиг с `home/.config/mewline` |
| `pawlette` | Перенести плагины и хуки из `home/.config/pawlette` |
| Скрипты | `home/.local/bin/*` — `screenshot.sh`, `volume.sh`, `brightness.sh`, `toggle-bar.sh`, `set-wallpaper.sh`, `screen-lock.sh`, `color-picker.sh`, `rofi-menus/*` |
| Темы загрузки | Пакеты для `meowrch/grub-theme` и `meowrch/plymouth-theme` |
| Тема VS Code | `misc/meowrch-theme-1.1.1.vsix` |
| Прочие дотфайлы | `micro`, `yazi`, `zsh`, `tmux`, `cava`, `lsd`, `alacritty`, `redshift`, `wireplumber`, `xsettingsd`, `tg-config`, `environment.d`, `uwsm`, `gtk-2.0/3.0/4.0` |
| `nemo-compare`, `pokemon-colorscripts`, `pyalsa` | Проверить наличие в nixpkgs или упаковать |

---

## ⚠️ Важно перед включением новых модулей

`modules/home/hyprland.nix` управляет каталогом `~/.config/hypr` через
Home Manager. В текущем `hosts/meowrch/home.nix` есть блок:

```nix
home.file.".config/hypr" = {
  source = ../../config/hypr;
  recursive = true;
  force = true;
};
```

Эти два способа **конфликтуют**. Перед включением `modules/home/hyprland.nix`
нужно убрать блок `home.file.".config/hypr"` из `hosts/meowrch/home.nix`.

### Отдельно про pawlette

Pawlette меняет конфиги **во время работы**, когда переключает тему. Файлы,
которые Home Manager кладёт симлинками в `/nix/store`, доступны только для
чтения — переключение тем по ним не сработает.

Для всех файлов, которые трогает pawlette, используйте существующий в репозитории
подход с `config.lib.file.mkOutOfStoreSymlink` на изменяемый путь в `~/.cache/meowrch/`
(как уже сделано для `zed/settings.json`), либо разворачивайте их через
`home.activation` копированием, а не симлинком.
