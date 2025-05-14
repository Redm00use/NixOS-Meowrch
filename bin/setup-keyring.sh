#!/bin/sh
# setup-keyring.sh - Скрипт для настройки переменных окружения gnome-keyring
# Используется для обеспечения работы хранилища ключей с Zed и другими приложениями

# Запуск gnome-keyring-daemon и экспорт переменных окружения
eval $(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)

# Установка переменных окружения
export SSH_AUTH_SOCK
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID
export GPG_AGENT_INFO

# Оповещаем о готовности хранилища
echo "GNOME Keyring daemon был запущен и переменные окружения настроены."
echo "SSH_AUTH_SOCK = $SSH_AUTH_SOCK"
echo "GNOME_KEYRING_CONTROL = $GNOME_KEYRING_CONTROL"

# Оповещаем systemd о переменных окружения
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    systemctl --user import-environment GNOME_KEYRING_CONTROL SSH_AUTH_SOCK GPG_AGENT_INFO
fi

# Запуск gnome-keyring-daemon в качестве ssh-agent
if [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/ssh_auth_sock" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    if [ -S "$HOME/.ssh/ssh_auth_sock" ]; then
        rm -f "$HOME/.ssh/ssh_auth_sock"
    fi
    mkdir -p "$HOME/.ssh"
    ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
fi