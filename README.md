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
        <a href="#-гайд-для-новичка-установка-программ">
            <img src="https://img.shields.io/badge/Guide-Install_Apps-orange?style=for-the-badge&logo=nixos&color=fab387&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="./docs/ALIASES.md">
            <img src="https://img.shields.io/badge/Wiki-Config_System-blue?style=for-the-badge&logo=bookstack&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!IMPORTANT]
> **Добро пожаловать в NixOS!** Если вы привыкли к Windows, Ubuntu или Arch — забудьте почти всё, что знали. В NixOS система строится из кода. Вы не «устанавливаете» программы, вы «описываете» их в конфиге.

## 📑 Содержание
- [✨ Особенности](#-особенности)
- [📁 Структура проекта](#-структура-проекта)
- [🚀 Установка](#-установка)
- [🔧 Использование и Обновление](#-использование-и-обновление)
- [📦 Гайд для новичка: Установка программ](#-гайд-для-новичка-установка-программ)
- [📖 Meowrch Wiki: Тонкая настройка](#-meowrch-wiki-тонкая-настройка)
- [⌨️ Хоткеи и Команды](#️-хоткеи-и-команды)
- [🛠️ Что делать, если всё сломалось?](#-что-делать-если-всё-сломалось)

## ✨ Особенности

| Feature | Implementation |
|---------|---------------|
| **Window Manager** | Hyprland (Wayland) с UWSM для стабильности |
| **Status Bar** | Mewline (Dynamic Island) — системный сервис |
| **Launcher** | Rofi с кастомными меню выбора тем/обоев |
| **Terminal** | Kitty (0.8 opacity) + Fish shell |
| **Shell** | Fish + Starship (minimalist prompt) |
| **Theming** | Catppuccin Mocha (GTK4 forced dark) |
| **GPU** | Умная поддержка AMD / Nvidia / Intel |

## 📁 Структура проекта

```text
NixOS-Meowrch/
├── hosts/meowrch/                         # Специфичные настройки для этой машины
├── modules/                               # Nix-модули (Система и Пользователь)
├── config/                                # "Сырые" конфиги (Hypr, Kitty, Fish...)
├── assets/                                # Статика (темы SDDM, обои, иконки)
├── scripts/                               # Все системные скрипты
├── pkgs/                                  # Описания кастомных пакетов
└── flake.nix                              # Точка входа в конфигурацию
```

## 🚀 Installation

### 1. Подготовка
Перед началом убедитесь, что у вас установлена NixOS. Вам понадобится **Git**:
```bash
nix-shell -p git
```

### 2. Установка
```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch
chmod +x install.sh
./install.sh
```

---

## 🔧 Использование и Обновление

Мы создали супер-команды (алиасы), чтобы вам было проще:

| Команда | Описание |
|---------|----------|
| `u` (или `г`) | **Полный апдейт**. Git pull + update hashes + flake update + rebuild. |
| `b` (или `и`) | **Применить настройки**. Запускайте после любых правок в конфигах. |
| `clean` | **Уборка**. Удаляет старые версии системы и чистит диск. |
| `rollback` | **Откат**. Вернуться к прошлому рабочему состоянию. |

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
];
```

### 2. Системные штуки (Драйверы, Утилиты)
Откройте `modules/nixos/packages/packages.nix` и добавьте пакет в `environment.systemPackages`.

**Как найти название пакета?**
Ищите на **[search.nixos.org](https://search.nixos.org/packages)**. Используйте "Attribute name".

**Как применить?**
Просто напишите в терминале: `b`

---

## 📖 Meowrch Wiki: Тонкая настройка

Основные файлы настройки Hyprland лежат в `modules/home/hypr-configs/`:

*   `keybindings.conf` — **Горячие клавиши**. Хотите поменять `Super+Q`? Вам сюда.
*   `windowrules.conf` — **Правила окон**. Здесь настраивается прозрачность и плавающие окна.
*   `monitors.conf` — **Экраны**. Настройка разрешения и частоты развертки.
*   `autostart.conf` — **Автозапуск**. Программы, которые включаются при старте.

---

## 🛠️ Что делать, если всё сломалось?

В NixOS невозможно окончательно «убить» систему программно!

1.  **Если не грузится**: Перезагрузитесь и выберите предыдущий пункт (Generation) в меню загрузки.
2.  **Если глючит**: Введите команду `rollback`. Система вернется в состояние до последней сборки.

---

## ⌨️ Хоткеи (Шпаргалка)

| Клавиша | Действие |
|---------|----------|
| `Super + Return` | Терминал (Kitty) |
| `Super + Q` | Закрыть окно |
| `Super + E` | Файловый менеджер (Nemo) |
| `Super + D` | Меню приложений (Rofi) |
| `Super + W` | Выбор обоев |
| `Super + Shift + T` | Выбор темы |
| `Super + L` | Заблокировать экран |
| `Super + Shift + B` | Переключить статус-бар |

---
<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
