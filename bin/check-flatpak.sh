#!/usr/bin/env bash

# Скрипт для проверки статуса Flatpak
# Автор: ChatGPT
# Дата: 2024

# Цветовые коды
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
RESET="\033[0m"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║            Проверка статуса Flatpak               ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${RESET}"

# Проверяем, установлен ли Flatpak
if command -v flatpak >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Flatpak установлен${RESET}"
    echo -e "Версия: $(flatpak --version)"
    echo ""
else
    echo -e "${RED}✗ Flatpak не установлен${RESET}"
    echo "Установите Flatpak с помощью NixOS модуля."
    exit 1
fi

# Проверка репозиториев
echo -e "${BLUE}Список репозиториев:${RESET}"
flatpak remotes

# Проверяем, добавлен ли Flathub
if flatpak remotes | grep -q "flathub"; then
    echo -e "\n${GREEN}✓ Flathub подключен${RESET}"
else
    echo -e "\n${RED}✗ Flathub не подключен${RESET}"
    echo "Включите поддержку Flathub в конфигурации NixOS."
fi

# Список установленных приложений
echo -e "\n${BLUE}Установленные Flatpak приложения:${RESET}"
if flatpak list | grep -q "Application"; then
    flatpak list --app
else
    echo -e "${YELLOW}Приложения Flatpak не установлены${RESET}"
    echo "Установите приложения с помощью команды: flatpak install flathub <идентификатор приложения>"
    echo "Пример: flatpak install flathub org.mozilla.firefox"
fi

# Проверка обновлений
echo -e "\n${BLUE}Проверка обновлений:${RESET}"
flatpak update --appstream

exit 0