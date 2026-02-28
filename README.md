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
</div>

> [!NOTE]
> Порт оригинального **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) на **NixOS**.
> Полная совместимость с экосистемой Nix, декларативность, воспроизводимость и стабильность.

## 📑 Содержание
- [✨ Особенности](#-особенности)
- [📁 Структура проекта](#-структура-проекта)
- [🚀 Установка](#-установка)
- [🔧 Использование и Обновление](#-использование-и-обновление)
- [📦 Гайд по пакетам](#-гайд-по-пакетам)
- [📖 Meowrch Wiki (Настройка)](#-meowrch-wiki-настройка)
- [⌨️ Хоткеи и Команды](#️-хоткеи-и-команды)

## ✨ Особенности

| Особенность | Реализация |
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
| **GPU** | Умная поддержка AMD / Nvidia / Intel |

## 📁 Структура проекта

```text
NixOS-Meowrch/
├── flake.nix                       # Главная точка входа (Flake)
├── hosts/                          # Конфигурации конкретных машин
│   └── meowrch/                    # Хост 'meowrch' (System + Home Manager)
├── modules/                        # Модульная логика Nix
│   ├── nixos/                      # Системные модули NixOS (драйверы, сервисы)
│   └── home/                       # Модули Home Manager (программы, конфиги)
├── config/                         # "Сырые" конфигурации приложений (symlinks)
│   ├── hypr/                       # Настройки Hyprland
│   ├── kitty/                      # Настройки Kitty
│   └── ...                         # Fish, Fastfetch, Btop
├── assets/                         # Статические ресурсы (SDDM, темы, обои)
├── scripts/                        # Консолидированные системные скрипты
└── pkgs/                           # Определения кастомных пакетов
```

## 🚀 Установка

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

## 🔧 Использование и Обновление

Для управления системой добавлены удобные алиасы (работают в любой раскладке):

| Алиас | Рус. | Описание |
|-------|------|----------|
| `u`     | `г`  | **Полное обновление**: git pull + update hashes + flake update + rebuild |
| `b`     | `и`  | **Быстрая пересборка**: применить текущие изменения в конфиге |
| `clean` | -    | **Очистка**: удалить старые поколения и собрать мусор |
| `rollback`| -  | **Откат**: вернуться к предыдущему удачному состоянию системы |

## 📦 Гайд по пакетам

В NixOS пакеты не устанавливаются через `apt` или `pacman`. Они описываются в конфигах.

1.  **Пользовательские приложения** (Firefox, Telegram и др.):
    Файл: `hosts/meowrch/home.nix` → раздел `home.packages`.
2.  **Системные утилиты и драйверы**:
    Файл: `modules/nixos/packages/packages.nix` → раздел `environment.systemPackages`.

После изменения файлов выполните команду `b` (или `и`) для применения.

## 📖 Meowrch Wiki (Настройка)

Основные файлы настройки Hyprland теперь находятся здесь:
`modules/home/hypr-configs/`

*   `keybindings.conf` — редактирование горячих клавиш.
*   `windowrules.conf` — правила для окон (плавающие, прозрачность).
*   `monitors.conf` — настройка мониторов и разрешений.
*   `autostart.conf` — приложения при запуске.

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
| `Super + C` | Пипетка (Color Picker) |
| `Super + Shift + H` | Шпаргалка по хоткеям |
| `Ctrl + Shift + R` | Перезагрузить Hyprland |
| `Super + Delete` | Выход из системы |

---
<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
