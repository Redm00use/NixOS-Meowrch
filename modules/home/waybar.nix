# Waybar — АЛЬТЕРНАТИВНЫЙ бар сессии Hyprland. Основной — mewline.
#
#   WM_BARS["hyprland"]="mewline waybar"   (scripts/toggle-bar.sh)
#   SUPER+SHIFT+B → toggle-bar.sh --next --wm hyprland → mewline ↔ waybar
#
# Конфиг upstream использует модули hyprland/workspaces и hyprland/language,
# то есть этот бар только для Wayland-сессии. В bspwm его аналог — polybar.
#
# АРХИТЕКТУРА PAWLETTE (важно для NixOS):
#   upstream кладёт в ~/.config/waybar ТОЛЬКО шаблоны:
#     config.jsonc.pawlette и style.css.pawlette с плейсхолдерами {{color_*}}.
#   Готовые config.jsonc и style.css генерит pawlette при применении темы.
#
#   Поэтому:
#     • шаблоны — симлинки в /nix/store (декларативно, правятся в репозитории);
#     • сгенерированные файлы — НЕ через xdg.configFile, а реальными записываемыми
#       файлами из activation-скрипта и только если их ещё нет.
#       Если положить config.jsonc симлинком в стор, pawlette упадёт на записи.
#
#   Фолбэк-генерация нужна ещё и потому, что без неё до первого запуска pawlette
#   в ~/.config/waybar лежат только шаблоны — waybar не найдёт конфиг и не стартует.

{ config, lib, pkgs, ... }:
let
  # Фолбэк-палитра: Catppuccin Mocha. Согласована с цветами рамок Hyprland из
  # default/appearance.lua upstream (col.active_border = b4befe/697dfd,
  # col.inactive_border = 45475a) и с catppuccin mocha/blue из hosts/meowrch/home.nix,
  # чтобы бар не разъезжался с остальной системой до первой темы pawlette.
  #
  # Порядок важен: "{{color_primary | lighten 10}}" должен идти ДО
  # "{{color_primary}}", иначе останется хвост " | lighten 10}}".
  subst = builtins.replaceStrings
    [
      "{{color_primary | lighten 10}}"
      "{{color_primary}}"
      "{{color_selection_bg}}"
      "{{color_bg}}"
      "{{color_text}}"
      "{{color_red}}"
      "{{color_green}}"
      "{{color_yellow}}"
      "{{color_blue}}"
    ]
    [
      "#c9d0fe"
      "#b4befe"
      "#585b70"
      "#1e1e2e"
      "#cdd6f4"
      "#f38ba8"
      "#a6e3a1"
      "#f9e2af"
      "#89b4fa"
    ];

  configTemplate = ../../config/waybar/config.jsonc.pawlette;
  styleTemplate = ../../config/waybar/style.css.pawlette;

  fallbackConfig =
    pkgs.writeText "waybar-config.jsonc" (subst (builtins.readFile configTemplate));
  fallbackStyle =
    pkgs.writeText "waybar-style.css" (subst (builtins.readFile styleTemplate));

  waybarDir = "${config.xdg.configHome}/waybar";
in
{
  home.packages = with pkgs; [
    waybar

    # "icon-theme": "Tela-circle-dracula" в модуле wlr/taskbar
    (tela-circle-icon-theme.override { colorVariants = [ "dracula" ]; })

    # on-click модуля custom/bluetooth → blueman-manager
    blueman

    # custom/cpu|ram|gpu вызывают "python .../system-info.py".
    # Именно python, не python3 — поэтому нужен алиас python в PATH.
    (python3.withPackages (ps: with ps; [ psutil ]))

    # custom/media и on-click playerctl play-pause / next
    playerctl
  ];

  # Шаблоны — декларативно, ПОФАЙЛОВО. Весь каталог линковать нельзя:
  # pawlette должен иметь возможность писать туда результат генерации.
  xdg.configFile."waybar/config.jsonc.pawlette".source = configTemplate;
  xdg.configFile."waybar/style.css.pawlette".source = styleTemplate;

  home.activation.seedWaybarGenerated =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArg waybarDir}

      if [ ! -e ${lib.escapeShellArg "${waybarDir}/config.jsonc"} ]; then
        run install -m 644 ${fallbackConfig} ${lib.escapeShellArg "${waybarDir}/config.jsonc"}
      fi

      if [ ! -e ${lib.escapeShellArg "${waybarDir}/style.css"} ]; then
        run install -m 644 ${fallbackStyle} ${lib.escapeShellArg "${waybarDir}/style.css"}
      fi
    '';

  # TODO(паритет): модуль custom/networkmanager вызывает
  # rofi-menus/network-manager.sh. Этого скрипта не было в ранее сверенном
  # списке scripts/rofi-menus форка — проверить отдельно, иначе индикатор
  # сети и клик по нему будут пустыми.
  #
  # TODO(паритет): system-update.sh в форке переписан под nix (больше upstream
  # по размеру), но конфиг waybar передаёт ему CHECKUPDATES_DB и флаги
  # --status --unupdated-color/--updated-color. Надо сверить, что форковая
  # версия их понимает.
}
