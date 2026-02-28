#!/usr/bin/env bash
sleep 1

# Gracefully kill existing portals
for portal in \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-kde \
    xdg-desktop-portal-lxqt \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal
do
    pkill -x "$portal" 2>/dev/null || true
done

sleep 1

# On NixOS portals live in /run/current-system/sw/libexec
# On other distros they are in /usr/lib or /usr/libexec
find_portal_bin() {
    local name="$1"
    for dir in \
        /run/current-system/sw/libexec \
        /usr/lib \
        /usr/libexec \
        /usr/local/libexec
    do
        if [ -x "$dir/$name" ]; then
            echo "$dir/$name"
            return
        fi
    done
    # Fallback: use PATH
    command -v "$name" 2>/dev/null || true
}

PORTAL_HYPR=$(find_portal_bin "xdg-desktop-portal-hyprland")
PORTAL_MAIN=$(find_portal_bin "xdg-desktop-portal")

if [ -n "$PORTAL_HYPR" ]; then
    "$PORTAL_HYPR" &
    sleep 2
fi

if [ -n "$PORTAL_MAIN" ]; then
    "$PORTAL_MAIN" &
fi
