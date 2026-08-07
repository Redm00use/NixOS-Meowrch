# SwayNotificationCenter — демон уведомлений Wayland-сессии.
# В X11/bspwm его аналог — dunst (modules/home/dunst.nix в форке уже есть).
#
# На swaync уже ссылаются три места в modules/home/hyprland.nix:
#   • exec-once  → uwsm-launcher.sh -t service -s s swaync
#   • SUPER+N    → swaync-client -t
#   • layerrule  → blur для swaync-notification-window и swaync-control-center
# без этого модуля они вели в пустоту.
#
# Два типа файлов, разное обращение:
#   config.json         — НЕ шаблон, линкуется декларативно;
#   style.css.pawlette  — шаблон, style.css генерит pawlette.
#
# В config.json стоит "cssPriority": "user", то есть swaync читает именно
# ~/.config/swaync/style.css. Поэтому та же схема, что в waybar.nix: шаблон
# симлинком в стор, готовый style.css — реальным записываемым файлом
# и только если его ещё нет.

{ config, lib, pkgs, ... }:
let
  # Фолбэк-палитра Catppuccin Mocha — та же, что в modules/home/waybar.nix.
  #
  # Порядок строго от более специфичного к менее: варианты с "| alpha NN"
  # обязаны идти ДО голых ключей, иначе останется хвост " | alpha 80}}".
  #
  # Фильтр "| alpha NN" у pawlette — это процент непрозрачности,
  # разворачиваем его в rgba(), потому что GTK CSS ждёт здесь цвет, а не хекс.
  subst = builtins.replaceStrings
    [
      "{{color_bg | alpha 80}}"
      "{{color_bg_alt | alpha 80}}"
      "{{color_bg_alt | alpha 30}}"
      "{{color_bg_alt}}"
      "{{color_bg}}"
      "{{color_text_muted}}"
      "{{color_text_subtle}}"
      "{{color_text}}"
      "{{color_surface}}"
      "{{color_selection_bg}}"
      "{{color_border_active}}"
      "{{color_primary}}"
      "{{color_red}}"
    ]
    [
      "rgba(30, 30, 46, 0.8)"
      "rgba(24, 24, 37, 0.8)"
      "rgba(24, 24, 37, 0.3)"
      "#181825"
      "#1e1e2e"
      "#a6adc8"
      "#bac2de"
      "#cdd6f4"
      "#313244"
      "#585b70"
      "#b4befe"
      "#b4befe"
      "#f38ba8"
    ];

  styleTemplate = ../../config/swaync/style.css.pawlette;

  fallbackStyle =
    pkgs.writeText "swaync-style.css" (subst (builtins.readFile styleTemplate));

  swayncDir = "${config.xdg.configHome}/swaync";
in
{
  home.packages = with pkgs; [
    swaynotificationcenter
  ];

  # Обычный конфиг — можно декларативно.
  # Отдельными файлами, чтобы ~/.config/swaync остался записываемым.
  xdg.configFile."swaync/config.json".source = ../../config/swaync/config.json;
  xdg.configFile."swaync/style.css.pawlette".source = styleTemplate;

  home.activation.seedSwayncStyle =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArg swayncDir}

      if [ ! -e ${lib.escapeShellArg "${swayncDir}/style.css"} ]; then
        run install -m 644 ${fallbackStyle} ${lib.escapeShellArg "${swayncDir}/style.css"}
      fi
    '';

  # Замечание: в config.json указан "$schema": "/etc/xdg/swaync/configSchema.json".
  # На NixOS этого пути нет (схема лежит в /nix/store/...-swaync/etc/xdg).
  # На работу не влияет — поле нужно только редакторам для автодополнения,
  # поэтому оставлено 1:1 с upstream.
}
