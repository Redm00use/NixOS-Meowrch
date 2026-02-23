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
| **Status Bar** | Waybar + Mewline (Dynamic Island) |
| **Launcher** | Rofi с кастомными меню |
| **Terminal** | Kitty с Catppuccin Mocha |
| **Shell** | Fish + Starship prompt |
| **Notifications** | Dunst (notification daemon) |
| **Lock Screen** | Swaylock |
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
├── flake.lock                             # Залоченные зависимости
├── configuration.nix                      # Системная конфигурация
├── install.sh                             # Автоматический установщик
│
├── modules/
│   ├── system/
│   │   ├── audio.nix                      # PipeWire аудио
│   │   ├── bluetooth.nix                  # Bluetooth стек
│   │   ├── graphics.nix                   # База GPU (Mesa, Vulkan)
│   │   ├── graphics-amd.nix              # AMD: amdgpu, RADV
│   │   ├── graphics-nvidia.nix           # Nvidia: проприетарный драйвер
│   │   ├── graphics-intel.nix            # Intel: i915, iHD VA-API
│   │   ├── networking.nix                 # Сеть, NetworkManager
│   │   ├── security.nix                   # Безопасность, firewall
│   │   ├── services.nix                   # Системные сервисы
│   │   └── fonts.nix                      # Шрифты (Nerd Fonts, Noto)
│   │
│   ├── desktop/
│   │   ├── hyprland.nix                   # Конфиг Hyprland (WM)
│   │   ├── sddm.nix                      # Дисплей-менеджер SDDM
│   │   └── theming.nix                   # Темы рабочего стола
│   │
│   └── packages/
│       └── packages.nix                   # Системные пакеты
│
├── home/
│   ├── home.nix                           # Home Manager (точка входа)
│   └── modules/
│       ├── fish.nix                       # Fish shell + алиасы
│       ├── git.nix                        # Git конфиг
│       ├── gtk.nix                        # GTK/Qt темы
│       ├── kitty.nix                      # Терминал Kitty
│       ├── rofi.nix                       # Лаунчер Rofi
│       ├── dunst.nix                      # Уведомления Dunst
│       └── hyprland.nix                   # Пользовательский конфиг WM
│
├── pkgs/
│   ├── mewline/                           # Dynamic Island bar
│   ├── fabric/                            # Фреймворк виджетов
│   ├── hotkeyhub/                         # Шпаргалка по хоткеям
│   ├── pawlette/                          # Менеджер тем
│   ├── meowrch-settings/                  # Оптимизации системы
│   └── meowrch-tools/                     # Утилиты Meowrch
│
├── packages/
│   ├── meowrch-scripts.nix               # Обвязка для скриптов
│   └── meowrch-themes.nix                # GTK/Qt темы Meowrch
│
├── dotfiles/                              # Конфиги приложений
└── scripts/
    └── update-pkg-hashes.sh              # Обновление хешей пакетов
```

## 🚀 Installation

### Требования
- Работающая установка NixOS (минимальная ISO или существующая система)
- Интернет-соединение

### Установка

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

# Откатиться на предыдущее поколение
sudo nixos-rebuild switch --rollback
```

### Хоткеи Hyprland

| Клавиша | Действие |
|---------|----------|
| `Super + Return` | Терминал (Kitty) |
| `Super + A` | Лаунчер (Rofi) |
| `Super + E` | Файловый менеджер (Nemo) |
| `Super + Q` | Закрыть окно |
| `Super + Space` | Переключить floating |
| `Super + 1-0` | Переключить workspace |
| `Super + Shift + 1-0` | Переместить окно на workspace |
| `Super + стрелки` | Фокус по направлению |
| `Super + L` | Заблокировать экран |
| `Super + X` | Меню питания |
| `Super + W` | Выбор обоев |
| `Super + V` | Менеджер буфера обмена |
| `Super + B` | Показать/скрыть Waybar |
| `Print` | Скриншот (область) |
| `Super + Print` | Скриншот (весь экран) |
| `XF86Audio*` | Громкость |
| `XF86MonBrightness*` | Яркость |

## 🎨 Theming

Вся система использует **Catppuccin Mocha** с **Blue** accent:

| Элемент | Цвет |
|---------|------|
| Background | `#1e1e2e` |
| Foreground | `#cdd6f4` |
| Accent (Blue) | `#89b4fa` |
| Secondary (Pink) | `#f5c2e7` |
| Error (Red) | `#f38ba8` |
| Success (Green) | `#a6e3a1` |
| Warning (Peach) | `#fab387` |

## 📝 Customisation

### Добавить пакеты
- **Системные**: `modules/packages/packages.nix`
- **Пользовательские**: `home/home.nix`
- **Флейк-входы**: `flake.nix`

### Настроить GPU

Модуль GPU выбирается автоматически при установке. Если нужно сменить:

```nix
# В configuration.nix — замените строку с GPU_MODULE_LINE:
./modules/system/graphics-amd.nix     # для AMD
./modules/system/graphics-nvidia.nix  # для Nvidia
./modules/system/graphics-intel.nix   # для Intel
```

### Настроить монитор

```nix
# В home/modules/hyprland.nix:
monitor = [
  ",preferred,auto,1"    # Стандартно
  # ",preferred,auto,2"  # HiDPI (масштаб 2x)
];
```

## 👤 Авторство

| | |
|---|---|
| **Оригинальный проект** | [Meowrch (Arch Linux)](https://github.com/meowrch/meowrch) |
| **Порт на NixOS** | [@Redm00us](https://t.me/Redm00us) |
| **Telegram** | [@meowrch](https://t.me/meowrch) |

## 📜 License

Этот проект основан на [Meowrch](https://github.com/meowrch/meowrch) (MIT License).

<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
