#!/bin/sh
# start-zed.sh - Скрипт для запуска Zed с правильной интеграцией с gnome-keyring

# Проверка и установка переменных окружения
if [ -z "$GNOME_KEYRING_CONTROL" ]; then
    eval $(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)
    export SSH_AUTH_SOCK
    export GNOME_KEYRING_CONTROL
fi

# Проверка разблокировки связки ключей
if ! secret-tool list > /dev/null 2>&1; then
    # Связка ключей заблокирована, запрашиваем пароль
    gnome-keyring-daemon --unlock
fi

# Запуск Zed
exec zed-editor "$@"