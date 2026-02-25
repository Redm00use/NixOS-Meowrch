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
            <img src="https://img.shields.ok/badge/Telegram-Meowrch-blue?style=for-the-badge&logo=telegram&color=a6e3a1&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="#-установка-пакетов-гайд">
            <img src="https://img.shields.io/badge/Guide-Install_Apps-orange?style=for-the-badge&logo=nixos&color=fab387&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!NOTE]
> Порт оригинального **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) на **NixOS**.
> Полная совместимость с экосистемой Nix, декларативность, воспроизводимость и стабильность.

## ✨ Features

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

## 📁 Project Structure

```
NixOS-Meowrch/
├── flake.nix                              # Точка входа (flake)
├── configuration.nix                      # Системная конфигурация
├── home/                                  # Настройки Home Manager
├── pkgs/                                  # Кастомные пакеты (Mewline, HotkeyHub...)
├── dotfiles/                              # Конфиги приложений
└── scripts/                               # Скрипты обслуживания
```

## 🚀 Installation

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

## ⌨️ Хоткеи и Команды

### Хоткеи Hyprland

| Клавиша | Действие |
|---------|----------|
| **Основные** | |
| `Super + Return` | Терминал (Kitty) |
| `Super + Q` | Закрыть окно |
| `Super + K` | Убить процесс окна |
| `Super + Space` | Переключить плавающее окно |
| `Alt + Return` | Полноэкранный режим |
| `Super + Delete` | Выход из Hyprland |
| `Ctrl + Shift + R` | Перезагрузить конфиг |
| **Навигация** | |
| `Super + Arrows` | Фокус окна (← ↓ ↑ →) |
| `Super + 1-0` | Перейти на рабочий стол 1-10 |
| `Super + Shift + 1-0` | Переместить окно на стол 1-10 |
| `Super + Ctrl + Left/Right` | Предыдущий/следующий рабочий стол |
| **Приложения и Меню** | |
| `Super + D` | Лаунчер приложений (Rofi) |
| `Super + E` | Файловый менеджер (Nemo) |
| `Super + V` | Менеджер буфера обмена |
| `Super + W` | Выбор обоев (Rofi) |
| `Super + T` | Выбор темы (Pawlette) |
| `Super + X` | Меню питания |
| `Super + code:60` (.) | Эмодзи меню |
| `Super + /` | Шпаргалка по хоткеям |
| `Super + Shift + H` | Шпаргалка по хоткеям |
| **Система и Утилиты** | |
| `Super + L` | Заблокировать экран |
| `Super + C` | Пипетка (Color Picker) |
| `Super + Shift + B` | Переключить статус-бар (Mewline) |
| `Super + N` | Центр уведомлений (SwayNC) |
| `Print` | Скриншот (область) |
| `Super + Alt + Shift + 3` | Скриншот всего экрана |
| `Super + Alt + Shift + 4` | Скриншот области |
| **Mewline (Dynamic Island)** | |
| `Super + Alt + P` | Открыть Power Menu |
| `Super + Alt + D` | Открыть Дату/Уведомления |
| `Super + Alt + B` | Открыть Bluetooth |
| `Super + Alt + A` | Открыть App Launcher |
| `Super + Alt + W` | Открыть Wallpapers |
| `Super + Alt + code:60` | Открыть Emoji |

## 📦 Установка пакетов (Гайд)

В NixOS пакеты не устанавливаются через `apt install` или `pacman -S`. Вместо этого они **декларируются** в конфигурации.

### 1. Где искать пакеты?
Используйте официальный поиск: **[search.nixos.org](https://search.nixos.org/packages)**.
*   Выберите ветку **25.11** (она соответствует вашей системе).
*   Скопируйте название пакета (например, `telegram-desktop`).

### 2. Куда вписывать?
Для редактирования файлов используйте предустановленный **Zed IDE** (команда `zed` в терминале или через меню приложений).

В этом конфиге есть два основных места:

*   **Пользовательские приложения** (рекомендуется):
    Файл: `home/home.nix` → раздел `home.packages`.
    *Сюда пишем браузеры, мессенджеры, плееры.*
*   **Системные утилиты**:
    Файл: `modules/packages/packages.nix` → раздел `environment.systemPackages`.
    *Сюда пишем драйверы, системные библиотеки, консольные тулзы.*

### 3. Как применить?
После того как вы вписали название пакета в список, сохраните файл и выполните команду:
```bash
rebuild
```
Система сама скачает пакет и добавит его в меню приложений.

### 4. Временная установка (без конфига)
Если программа нужна на один раз:
```bash
nix shell nixpkgs#название_пакета
```
Программа будет доступна, пока вы не закроете терминал.

### Алиасы терминала (Fish)

| Алиас | Команда | Описание |
|-------|---------|----------|
| `rebuild` | `sudo nixos-rebuild switch...` | Пересобрать систему из flake |
| `update-pkgs` | `./scripts/update-pkg-hashes.sh && ...` | Обновить хэши всех пакетов и пересобрать |
| `update` | `nix flake update && rebuild` | Обновить flake.lock и пересобрать систему |
| `cleanup` | `sudo nix-collect-garbage -d` | Очистка старых поколений и мусора |
| `optimize` | `sudo nix-store --optimise` | Оптимизация Nix store (экономия места) |
| `rollback` | `sudo nixos-rebuild switch --rollback` | Откат к предыдущему состоянию |
| `cls` | `clear` | Очистить экран |
| `ll` | `ls -la` | Список файлов с деталями |
| `validate` | `./validate-config.sh` | Проверка синтаксиса конфигурации |

## 🎨 Theming

Вся система использует **Catppuccin Mocha** с **Blue** accent.

## 👤 Авторство

| | |
|---|---|
| **Оригинальный проект** | [Meowrch (Arch Linux)](https://github.com/meowrch/meowrch) |
| **Порт на NixOS** | [@Redm00us](https://t.me/Redm00us) |
| **Telegram** | [@meowrch](https://t.me/meowrch) |

<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
