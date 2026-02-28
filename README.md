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

## 📁 Структура проекта

```text
NixOS-Meowrch/
├── flake.nix                       # Главная точка входа (Flake)
├── hosts/                          # Конфигурации конкретных машин
│   └── meowrch/                    # Хост 'meowrch' (NixOS + Home Manager)
├── modules/                        # Модульная логика Nix
│   ├── nixos/                      # Системные модули NixOS
│   └── home/                       # Модули Home Manager (Fish, Hyprland, etc.)
├── config/                         # "Сырые" конфигурации приложений (symlinks)
├── assets/                         # Статические ресурсы (SDDM, темы, обои)
├── scripts/                        # Консолидированные системные скрипты
├── pkgs/                           # Определения кастомных пакетов
└── install.sh                      # Инсталлятор системы
```

## 🔧 Использование (Алиасы)

Для удобства в систему добавлены короткие команды (работают в обеих раскладках):

| Команда | Рус. | Описание |
|---------|------|----------|
| `u`     | `г`  | **Полный апдейт**: git pull + update pkgs + flake update + rebuild |
| `b`     | `и`  | **Быстрый ребилд**: применить текущие изменения в конфиге |
| `clean` | -    | **Очистка**: удалить старые поколения и собрать мусор |
| `search`| -    | **Поиск**: найти пакет в nixpkgs |
| `rollback`| -  | **Откат**: вернуться к предыдущему удачному состоянию |

## ⌨️ Хоткеи Hyprland

| Клавиша | Действие |
|---------|----------|
| `Super + Return` | Терминал (Kitty) |
| `Super + Q` | Закрыть окно |
| `Super + D` | Лаунчер приложений (Rofi) |
| `Super + E` | Файловый менеджер (Nemo) |
| `Super + V` | Менеджер буфера обмена |
| `Super + W` | Выбор обоев (Rofi) |
| `Super + T` | Выбор темы (Pawlette) |
| `Super + X` | Меню питания |
| `Super + L` | Заблокировать экран |
| `Super + Shift + B` | Переключить статус-бар (Mewline) |

## 📦 Установка пакетов

1.  Найдите пакет на **[search.nixos.org](https://search.nixos.org/packages)**.
2.  Добавьте его в `hosts/meowrch/home.nix` (для приложений) или `modules/nixos/packages/packages.nix` (для системных утилит).
3.  Выполните команду `b` (или `и`) для пересборки.

## 📖 Meowrch Wiki (Настройка)

Все основные настройки Hyprland лежат в `modules/home/hypr-configs/`:
*   `keybindings.conf` — горячие клавиши.
*   `windowrules.conf` — правила окон.
*   `monitors.conf` — настройки экранов.

---
<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
