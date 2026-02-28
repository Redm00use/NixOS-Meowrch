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

## 🔧 Использование и Обновление

| Алиас | Рус. | Описание |
|-------|------|----------|
| `u`     | `г`  | **Полный апдейт**: git pull + update hashes + flake update + rebuild |
| `b`     | `и`  | **Быстрый ребилд**: применить изменения в конфиге |
| `clean` | -    | **Уборка**: удалить старые поколения и собрать мусор |
| `rollback`| -  | **Откат**: вернуться к предыдущему удачному состоянию |

---

## 📦 Гайд для новичка: Установка программ

В NixOS пакеты записываются в списки. Есть два главных списка:

### 1. Программы для вас (Браузеры, Плееры, Игры)
Откройте файл `hosts/meowrch/home.nix` (команда `zed ~/NixOS-Meowrch/hosts/meowrch/home.nix`).
Найдите раздел `home.packages` и добавьте название:
```nix
home.packages = with pkgs; [
  telegram-desktop
  vlc
];
```

### 2. Системные штуки (Драйверы, Утилиты)
Откройте `modules/nixos/packages/packages.nix` и добавьте пакет в `environment.systemPackages`.

**Как найти название пакета?**
Ищите на **[search.nixos.org](https://search.nixos.org/packages)**. 

**Как применить?**
Напишите в терминале: `b` (или `и`).

---

## 📖 Meowrch Wiki: Тонкая настройка

Здесь собраны инструкции по изменению внешнего вида и поведения вашей системы.

### 🖼️ Управление интерфейсом (Hyprland)
Все основные настройки находятся в `modules/home/hypr-configs/`. 

*   **Горячие клавиши**: Правьте `keybindings.conf`. Можно менять существующие или добавлять свои (например, запуск любимой игры).
*   **Правила окон**: В `windowrules.conf` можно заставить Spotify открываться на 10-м рабочем столе или сделать Telegram всегда плавающим.
*   **Анимации**: Файл `appearance.conf` содержит настройки `animations`. Можно сделать систему молниеносной или, наоборот, плавной и «кинематографичной».
*   **Мониторы**: Если у вас два монитора или нестандартное разрешение, правьте `monitors.conf`.

### 🎨 Темы, Обои и Шрифты
*   **Обои**: Чтобы добавить свои картинки в меню выбора (`Super + W`), просто закиньте их в `assets/wallpapers/`.
*   **Цвета**: Система использует **Catppuccin Mocha**. Если хотите изменить цвета терминала или баров, ищите файлы тем в `assets/themes/`.
*   **Шрифты**: Основной шрифт системы меняется в `modules/nixos/system/fonts.nix`.

### ⚙️ Скрипты и Автозапуск
*   **Скрипты**: Все «мозги» (регуляторы громкости, переключатели тем) лежат в папке `scripts/`. Вы можете использовать их в своих хоткеях.
*   **Автозапуск**: Чтобы программа запускалась сама при входе, добавьте её в `modules/home/hypr-configs/autostart.conf`.

### 📝 Редактор Zed (Ваш главный инструмент)
Мы настроили **Zed IDE** так, чтобы вам было удобно:
*   В нем уже есть поддержка Nix (подсветка ошибок, автоформатирование).
*   Настроены удобные хоткеи: `Ctrl + /` (комментарий), `Ctrl + D` (выделение).
*   Интеграция с Git: вы сразу видите, что изменили в конфигах.

---

## 🛠️ Что делать, если всё сломалось?

В NixOS невозможно окончательно «убить» систему программно!

1.  **Если не загружается**: Перезагрузитесь и выберите в меню пункт с предыдущей датой (Generation). Вы вернетесь во времени в рабочую систему.
2.  **Если что-то глючит после сборки**: Введите в терминале команду `rollback`.
3.  **Ошибка при сборке (`b`)**: Читайте текст ошибки. Обычно Nix пишет точно, в каком файле и строке вы допустили опечатку.

---

## ⌨️ Хоткеи (Шпаргалка)

| Клавиша | Действие |
|---------|----------|
| `Super + Return` | Терминал |
| `Super + Q` | Закрыть окно |
| `Super + E` | Файловый менеджер |
| `Super + D` | Меню всех программ |
| `Super + Z` | Браузер |
| `Super + T` | Telegram |
| `Super + L` | Заблокировать экран |
| `Super + Shift + B` | Переключить статус-бар |

---
<div align="center">
    <p><i>Сделано с ❤️ для сообщества NixOS и Meowrch</i></p>
    <p><sub>≽ܫ≼</sub></p>
</div>
