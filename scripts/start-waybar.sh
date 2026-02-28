#!/usr/bin/env bash
# Универсальный скрипт запуска/перезапуска Waybar для NixOS

# Завершаем текущие процессы
killall -q waybar

# Ожидаем завершения
while pgrep -x waybar >/dev/null; do sleep 1; done

# Запускаем Waybar
echo "Starting Waybar..."
waybar &
