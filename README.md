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
