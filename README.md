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
            <img src="https://img.shields.io/badge/Guide-Install_Apps-orange?style=for-the-badge&logo=nixos&color=fab387&logoColor=1e1e2e&labelColor=313244">
        </a>
        <a href="#-meowrch-wiki">
            <img src="https://img.shields.io/badge/Wiki-Config_System-blue?style=for-the-badge&logo=bookstack&color=89b4fa&logoColor=1e1e2e&labelColor=313244">
        </a>
    </p>
</div>

> [!NOTE]
> Порт оригинального **[Meowrch](https://github.com/meowrch/meowrch)** (Arch Linux) на **NixOS**.
> Полная совместимость с экосистемой Nix, декларативность, воспроизводимость и стабильность.

## 📑 Содержание
- [✨ Особенности](#-features)
- [📁 Структура проекта](#-project-structure)
- [🚀 Установка](#-installation)
- [📦 Гайд по пакетам](#-установка-пакетов-гайд)
- [📖 Meowrch Wiki](#-meowrch-wiki)
- [⌨️ Хоткеи и Команды](#️-хоткеи-и-команды)
- [🎨 Темы](#-theming)

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

### 1. Подготовка (Важно!)
Перед началом убедитесь, что у вас установлена NixOS (версия не важна: это может быть Minimal ISO, GNOME или KDE).

Для работы установщика вам понадобится **Git**. Если его еще нет, выполните:
```bash
# Временная установка git для клонирования
nix-shell -p git
```
*Либо добавьте `git` в `environment.systemPackages` вашего `/etc/nixos/configuration.nix` и сделайте `sudo nixos-rebuild switch`.*

### 2. Установка

```bash
# 1. Клонируйте репозиторий
git clone https://github.com/Redm00use/NixOS-Meowrch.git
cd NixOS-Meowrch

# 2. Запустите установщик
chmod +x install.sh
./install.sh
```

Установщик предложит:
1. **Режим** — обновить текущую систему или установить на новый диск
2. **Hostname** — имя вашей машины
3. **Username** — имя пользователя
4. **GPU** — AMD / Intel / Nvidia (автоматическая настройка модулей)
5. **Shell** — Fish / Zsh / Bash

### После установки

```bash
# Перезагрузка
reboot

# Добавить обои
cp ~/Pictures/*.{jpg,png} ~/.local/share/wallpapers/
```

## 🔧 Daily Usage

### Основные команды

```bash
# Пересборка после изменений
sudo nixos-rebuild switch --flake ~/meowrch-nixos#nixos

# Обновить все зависимости
cd ~/meowrch-nixos && nix flake update
sudo nixos-rebuild switch --flake .#nixos

# Очистить старые поколения
sudo nix-collect-garbage -d

# Откатиться на предыдущее состояние
sudo nixos-rebuild switch --rollback
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

## 📖 Meowrch Wiki

Добро пожаловать в базу знаний по настройке вашей системы! Здесь описано, как менять «поведение» рабочих столов и окон.

### 1. Где лежат настройки?
В нашей системе настройки Hyprland разделены на модули для удобства.
Все основные файлы находятся здесь:
`home/modules/hypr-configs/`

*   `keybindings.conf` — горячие клавиши (хоткеи).
*   `windowrules.conf` — правила для окон (плавающие окна, размеры).
*   `monitors.conf` — настройки мониторов и разрешений.
*   `autostart.conf` — приложения, которые запускаются сами при входе.

### 2. Как добавить свой хоткей?
Откройте `home/modules/hypr-configs/keybindings.conf` в **Zed IDE**.
Синтаксис простой:
`bind = МОДИФИКАТОР, КЛАВИША, ДЕЙСТВИЕ, КОМАНДА`

**Примеры:**
*   `bind = $mainMod, F, exec, firefox` — запуск Firefox по `Super + F`.
*   `bind = $subMod, G, exec, gimp` — запуск GIMP по `Super + Shift + G`.

### 3. Как настраивать правила окон?
Если вы хотите, чтобы программа всегда открывалась в определенном виде, правьте `home/modules/hypr-configs/windowrules.conf`.

**Полезные примеры:**
*   **Сделать окно плавающим**:
    `windowrule = float, ^(telegram-desktop)$`
*   **Задать точный размер**:
    `windowrule = size 800 600, ^(pavucontrol)$`
*   **Открыть на определенном воркспейсе**:
    `windowrule = workspace 3, ^(discord)$`
*   **Размытие фона (Blur)**:
    `layerrule = blur, rofi`

> [!TIP]
> Чтобы узнать "имя" окна (class) для правила, введите в терминале команду `hyprctl clients` или используйте утилиту `hyprprop`.

### 4. Как применить изменения?
Любые правки в файлах `.conf` в этой папке требуют пересборки:
```bash
rebuild
```
После завершения команды ваши новые хоткеи и правила вступят в силу мгновенно.

### Алиасы терминала (Fish)

| Алиас | Команда | Описание |
|-------|---------|----------|
| `rebuild` | `sudo nixos-rebuild switch...` | Пересобрать систему из flake |
| `update-pkgs` | `./scripts/update-pkg-hashes.sh && ...` | Обновить хэши всех пакетов и пересобрать |
| `update` | `nix flake update && rebuild` | Обновить flake.lock и пересобрать систему |
| `cleanup` | `sudo nix-collect-garbage -d` | Очистка старых поколений и мусора |
| `optimize` | `sudo nix-store --optimise` | Оптимизация Nix store (экономия места) |
| `generations` | `sudo nix-env --list-generations` | Список всех версий (поколений) системы |
| `rollback` | `sudo nixos-rebuild switch --rollback` | Откат к предыдущему удачному состоянию |
| `cls` | `clear` | Очистить экран |
| `ll` | `ls -la` | Список файлов с деталями |
| `validate` | `./validate-config.sh` | Проверка синтаксиса конфигурации |

## 🎨 Theming

Вся система использует **Catppuccin Mocha** с **Blue** accent.

## 👤 Авторство

| | |
|---|---|
| **Оригинальный проект** | [Meowrch (Arch Linux)](https://github.com/meowrch/meowrch) |
| **Порт на NixOS** | [@Redm00use](https://t.me/Redm00use) |
| **Telegram** | [@meowrch](https://t.me/meowrch) |

<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
