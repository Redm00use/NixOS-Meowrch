<div align="center">
    <img src=".meta/logo.png" width="300px">
    <h1>🐱 Meowrch NixOS</h1>
    <p><i>Красивая, декларативная и воспроизводимая конфигурация NixOS на базе <a href="https://github.com/meowrch/meowrch">Meowrch</a></i></p>
    <p>
        <a href="https://github.com/Redm00use/NixOS-Meowrch/stargazers">
            <img src="https://img.shields.io/github/stars/Redm00use/NixOS-Meowrch?style=for-the-badge&logo=star&color=cba6f7&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://github.com/Redm00use/NixOS-Meowrch/network/members">
            <img src="https://img.shields.io/github/forks/Redm00use/NixOS-Meowrch?style=for-the-badge&logo=git&color=f38ba8&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://nixos.org">
            <img src="https://img.shields.io/badge/NixOS-25.11-blue?style=for-the-badge&logo=nixos&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="https://t.me/meowrch">
            <img src="https://img.shields.io/badge/Telegram-Meowrch-blue?style=for-the-badge&logo=telegram&color=a6e3a1&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
    <p>
        <a href="#-установка">
            <img src="https://img.shields.io/badge/Install-Meowrch_NixOS-success?style=for-the-badge&logo=nixos&color=a6e3a1&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="#-гайд-для-новичка-установка-программ">
            <img src="https://img.shields.ok/badge/Guide-Install_Apps-orange?style=for-the-badge&logo=nixos&color=fab387&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="./docs/ALIASES.md">
            <img src="https://img.shields.io/badge/Wiki-Config_System-blue?style=for-the-badge&logo=bookstack&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!NOTE]
> Порт оригинального **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) на **NixOS**.
> Полная совместимость с экосистемой Nix, декларативность, воспроизводимость и стабильность.

## 📑 Содержание
- [✨ Особенности](#-особенности)
- [📁 Структура проекта](#-структура-проекта)
- [🚀 Установка](#-установка)
- [🔧 Использование и Обновление](#-использование-и-обновление)
- [📦 Гайд для новичка: Установка программ](#-гайд-для-новичка-установка-программ)
- [📖 Meowrch Wiki: Тонкая настройка](#-meowrch-wiki-тонкая-настройка)
- [⌨️ Хоткеи и Команды](#️-хоткеи-и-команды)
- [🛠️ Что делать, если всё сломалось?](#-что-делать-если-всё-сломалось)

---

## ✨ Особенности

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) с UWSM для максимальной стабильности |
| **Status Bar** | Mewline (Dynamic Island) — работает как системный сервис |
| **Launcher** | Rofi с кастомными меню выбора тем и обоев |
| **Session Manager** | UWSM (Universal Wayland Session Manager) |
| **Display Manager** | SDDM с темой Meowrch на базе **Qt6** |
| **Terminal** | Kitty (0.8 opacity) + Fish shell |
| **Shell** | Fish + Starship (minimalist prompt) |
| **Memory** | ZRAM включен по умолчанию |
| **Theming** | Catppuccin Mocha (GTK4/Libadwaita forced dark) |
| **GPU** | Умная поддержка AMD / Nvidia / Intel (авто-выбор) |
| **Editor** | Zed IDE с преднастроенной поддержкой Nix и AI |

---

## 📁 Структура проекта

```text
NixOS-Meowrch/
├── flake.nix                       # Главная точка входа (Flake)
├── flake.lock                      # Зафиксированные версии зависимостей
├── hosts/                          # Конфигурации конкретных машин
│   └── meowrch/                    # Хост 'meowrch'
│       ├── configuration.nix       # Системные настройки хоста
│       ├── hardware-configuration.nix # Настройки железа (авто-ген)
│       └── home.nix                # Пользовательские настройки (Home Manager)
├── modules/                        # Модульная логика Nix
│   ├── nixos/                      # Системные модули NixOS
│   │   ├── desktop/                # Окружение (Hyprland, SDDM, Theming)
│   │   ├── system/                 # Ядро (Audio, Fonts, Security, Networking)
│   │   └── packages/               # Глобальные пакеты и Flatpak
│   └── home/                       # Модули Home Manager
│       ├── fish.nix                # Shell-конфигурация
│       ├── starship.nix            # Prompt-конфигурация
│   └── hypr/                   # Конфиги Hyprland (Binds, Rules) в config/hypr/
│       └── ...                     # Rofi, GTK
├── config/                         # "Сырые" конфигурации приложений (symlinks)
│   ├── hypr/                       # Настройки Hyprland
│   ├── kitty/                      # Настройки Kitty
│   └── ...                         # Fish, Fastfetch, Btop
├── assets/                         # Статические ресурсы системы
│   ├── sddm/                       # Тема экрана входа (Qt6)
│   ├── themes/                     # Темы оформления (Catppuccin)
│   └── misc/                       # Прочее (.face.icon, лого)
├── scripts/                        # Консолидированные системные скрипты
│   ├── rofi-menus/                 # Скрипты Rofi (Power, VPN, Wallpaper)
│   └── ...                         # Утилиты управления (volume, backlight)
├── pkgs/                           # Определения кастомных пакетов (Derivations)
├── packages/                       # Nix-деривации для локальных папок
├── overlays/                       # Системные патчи (GBM fix, etc.)
└── docs/                           # Документация и архивы логов
```

---

## 🚀 Установка

### 1. Подготовка (Важно!)
Для максимально простой установки рекомендуется сначала установить чистую **NixOS с рабочим столом KDE Plasma** (используя официальный графический установщик). Это обеспечит наличие всех базовых драйверов и настроек.

После установки NixOS откройте терминал и подготовьте окружение:
```bash
# Временная установка git и python для запуска установщика
nix-shell -p git python3
```

> [!CAUTION]
> **ВАЖНО:** Не удаляйте и не перемещайте папку с репозиторием (`~/NixOS-Meowrch`) после установки! 
> В NixOS на Flakes эта папка является «сердцем» вашей системы. Без неё вы не сможете обновляться или менять настройки.

### 2. Установка

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.py
./install.py
```

---

## 🔧 Использование и Обновление

Мы создали супер-команды (алиасы), чтобы вам не нужно было учить сложные заклинания:

| Алиас | Рус. | Описание |
|-------|------|----------|
| `u`     | `г`  | **Полный апдейт**: git pull + update hashes + flake update + rebuild |
| `b`     | `и`  | **Быстрый ребилд**: применить текущие изменения в конфиге |
| `clean` | -    | **Уборка**: удалить старые поколения и собрать мусор |
| `rollback`| -  | **Откат**: вернуться к предыдущему удачному состоянию |

---

## 📦 Гайд для новичка: Установка программ

В NixOS пакеты не устанавливаются через `apt install`. Они описываются в конфигах.

### 1. Программы для вас (Браузеры, Плееры, Игры)
Откройте файл `hosts/meowrch/home.nix` (команда `zed ~/NixOS-Meowrch/hosts/meowrch/home.nix`).
Найдите раздел `home.packages` и добавьте название программы:
```nix
home.packages = with pkgs; [
  telegram-desktop
  vlc
  discord
];
```

### 2. Системные штуки (Драйверы, Утилиты)
Откройте `modules/nixos/packages/packages.nix` и добавьте пакет в `environment.systemPackages`.

**Как найти название пакета?**
Зайдите на **[search.nixos.org](https://search.nixos.org/packages)**. 

**Как применить?**
После сохранения файла просто напишите в терминале: `b` (или `и`).

---

## 📖 Meowrch Wiki: Тонкая настройка

Здесь собраны инструкции по изменению внешнего вида и поведения вашей системы.

### 🖼️ Управление интерфейсом (Hyprland)
Все основные настройки находятся в `config/hypr/`. 

*   **Горячие клавиши**: Правьте `keybindings.conf`. Можно менять существующие или добавлять свои (например, запуск любимой игры).
*   **Правила окон**: В `windowrules.conf` можно заставить Spotify открываться на 10-м рабочем столе или сделать Telegram всегда плавающим.
*   **Анимации**: Файл `appearance.conf` содержит настройки `animations`. Можно сделать систему молниеносной или, наоборот, плавной и «кинематографичной».
*   **Мониторы**: Настройка разрешения и частоты развертки в `monitors.conf`.

### 🎨 Темы, Обои и Шрифты
*   **Обои**: Чтобы добавить свои картинки в меню выбора (`Super + W`), просто закиньте их в `assets/wallpapers/`.
*   **Цвета**: Система использует **Catppuccin Mocha**. Если хотите изменить цвета терминала или баров, ищите файлы тем в `assets/themes/`.
*   **Шрифты**: Основной шрифт системы меняется в `modules/nixos/system/fonts.nix`.

### 📝 Редактор Zed (Ваш главный инструмент)
Мы настроили **Zed IDE** так, чтобы вам было удобно:
*   В нем уже есть поддержка Nix (подсветка ошибок, автоформатирование).
*   Интеграция с Git: вы сразу видите, что изменили в конфигах.
*   Удобные хоткеи: `Ctrl + /` (комментарий), `Ctrl + D` (выделение).

---

## 🛠️ Что делать, если всё сломалось?

Это NixOS, здесь **невозможно** окончательно «убить» систему программно!

1.  **Если система не загружается**: Перезагрузитесь. В меню загрузки (GRUB/Systemd-boot) выберите предыдущий пункт (Generation). Вы окажетесь в системе, которая работала до ваших правок.
2.  **Если вы в системе, но всё глючит**: Введите команду `rollback`. Система вернется к прошлому рабочему состоянию.

---

## ⌨️ Хоткеи и Команды

| Клавиша | Действие |
|---------|----------|
| `Super + Return` | Терминал (Kitty + Fish) |
| `Super + Q` | Закрыть окно |
| `Super + E` | Файловый менеджер (Nemo) |
| `Super + D` | Меню приложений (Rofi) |
| `Super + Z` | Браузер (Firefox) |
| `Super + T` | Telegram (Materialgram) |
| `Super + W` | Выбор обоев |
| `Super + Shift + T` | Выбор темы (Pawlette) |
| `Super + X` | Меню питания (Powermenu) |
| `Super + L` | Заблокировать экран |
| `Super + Shift + B` | Переключить статус-бар (Mewline) |
| `Print` | Скриншот (область) |

---
<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
