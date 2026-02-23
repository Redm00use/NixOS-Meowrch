#!/usr/bin/env fish
# Активируем виртуальное окружение
source /home/redm00us/myenv/bin/activate.fish

# Проверяем, что окружение активировано
if not test -n "$VIRTUAL_ENV"
    echo "Virtual environment not activated!"
    exit 1
end

# Запускаем Waybar
echo "Starting Waybar..."
waybar -l debug
