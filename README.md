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
        <a href="#-installation">
            <img src="https://img.shields.io/badge/Install-Meowrch_NixOS-success?style=for-the-badge&logo=nixos&color=a6e3a1&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="#-установка-пакетов-гайд">
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
- [📦 Гайд по пакетам](#-установка-пакетов-гайд)
- [📖 Meowrch Wiki](#-meowrch-wiki)
- [⌨️ Хоткеи и Команды](#️-хоткеи-и-команды)
- [🎨 Темы](#-theming)

## ✨ Особенности

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) с анимациями и размытием |
| **Status Bar** | Mewline (Dynamic Island) |
| **Launcher** | Rofi с кастомными меню |
| **Terminal** | Kitty с Catppuccin Mocha |
| **Shell** | Fish + Starship prompt |
| **Notifications** | SwayNC / Dunst |
| **Lock Screen** | Swaylock / Hyprlock |
| **Theme** | Catppuccin Mocha (GTK + Qt + terminal) |
| **Icons** | Papirus Dark |
| **Cursor** | Bibata Modern Classic |
| **GPU** | AMD / Nvidia / Intel (авто-выбор) |
| **Audio** | PipeWire |
| **Gaming** | Steam + Gamemode + MangoHud |

## 📁 Структура проекта

```text
NixOS-Meowrch/
├── hosts/meowrch/                         # Специфичные настройки для этой машины
├── modules/                               # Nix-модули (NixOS и Home Manager)
├── config/                                # "Сырые" конфиги (Hypr, Kitty, Fish...)
├── assets/                                # Статика (темы SDDM, обои, иконки)
├── scripts/                               # Все системные скрипты
├── pkgs/                                  # Описания кастомных пакетов
└── flake.nix                              # Точка входа в конфигурацию
```

## 🚀 Установка

### 1. Подготовка (Важно!)
Перед началом убедитесь, что у вас установлена NixOS (версия не важна: это может быть Minimal ISO, GNOME или KDE).

Для работы установщика вам понадобится **Git**. Если его еще нет, выполните:
```bash
# Временная установка git для клонирования
nix-shell -p git
```

> [!CAUTION]
> **ВАЖНО:** Не удаляйте и не перемещайте папку с репозиторием (`~/NixOS-Meowrch`) после установки! 
> В NixOS на Flakes эта папка является «сердцем» вашей системы. Без неё вы не сможете обновляться или менять настройки.

### 2. Установка

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

## 🔧 Использование и Обновление

### Основные команды (Алиасы)
Для удобства добавлены короткие команды (работают в любой раскладке):

| Команда | Рус. | Описание |
|---------|------|----------|
| `u`     | `г`  | **Полный апдейт**: git pull + update hashes + flake update + rebuild |
| `b`     | `и`  | **Быстрый ребилд**: применить изменения в конфиге |
| `clean` | -    | **Очистка**: удалить старые поколения и мусор |
| `rollback`| -  | **Откат**: вернуться к предыдущей рабочей версии |

## ⌨️ Хоткеи и Команды

| Клавиша | Действие |
|---------|----------|
| `Super + Return` | Терминал (Kitty) |
| `Super + Q` | Закрыть окно |
| `Super + D` | Лаунчер приложений (Rofi) |
| `Super + E` | Файловый менеджер (Nemo) |
| `Super + V` | Менеджер буфера обмена |
| `Super + W` | Выбор обоев (Rofi) |
| `Super + Shift + T` | Выбор темы (Pawlette) |
| `Super + X` | Меню питания |
| `Super + code:60` (.) | Эмодзи меню |
| `Super + L` | Заблокировать экран |
| `Super + Shift + B` | Переключить статус-бар (Mewline) |
| `Print` | Скриншот (область) |

## 📦 Установка пакетов (Гайд)

В NixOS пакеты не устанавливаются через `apt install`. Они описываются в конфигах.

### 1. Где искать пакеты?
Используйте официальный поиск: **[search.nixos.org](https://search.nixos.org/packages)**.

### 2. Куда вписывать?
Для редактирования используйте **Zed IDE** (команда `zed`).

В этом конфиге есть два основных места:
*   **Пользовательские приложения** (рекомендуется):
    Файл: `hosts/meowrch/home.nix` → раздел `home.packages`.
*   **Системные утилиты**:
    Файл: `modules/nixos/packages/packages.nix` → раздел `environment.systemPackages`.

### 3. Как применить?
Выполните команду:
`b` (или `и`)

## 📖 Meowrch Wiki

Добро пожаловать в базу знаний по настройке системы! 

### 1. Где лежат настройки?
Основные файлы Hyprland теперь находятся здесь:
`modules/home/hypr-configs/`

*   `keybindings.conf` — горячие клавиши (хоткеи).
*   `windowrules.conf` — правила для окон.
*   `monitors.conf` — настройки мониторов.
*   `autostart.conf` — автозапуск приложений.

### 2. Как добавить свой хоткей?
Откройте `modules/home/hypr-configs/keybindings.conf` в Zed.
Синтаксис: `bind = МОДИФИКАТОР, КЛАВИША, ДЕЙСТВИЕ, КОМАНДА`

## 🎨 Theming

Вся система использует **Catppuccin Mocha** с **Blue** accent.

---
<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
