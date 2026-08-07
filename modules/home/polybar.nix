# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  Polybar — бар для X11/bspwm-сессии (паритет с meowrch 4.1.1)              ║
# ║                                                                            ║
# ║  Источник: home/.config/polybar/config.ini.pawlette (9.5 КБ)               ║
# ║            home/.config/polybar/launch.sh                                  ║
# ║                                                                            ║
# ║  ВАЖНО: тут НЕТ services.polybar!                                          ║
# ║  HM-модуль services.polybar поднял бы systemd-юнит, который конфликтует    ║
# ║  с toggle-bar.sh: тот владеет полибаром через killall/pgrep, а systemd     ║
# ║  поднимал бы его заново. Ровно та же ошибка, что сейчас есть с mewline     ║
# ║  в hosts/meowrch/home.nix. Полибар запускает toggle-bar.sh --wm bspwm,     ║
# ║  вызывая ~/.config/polybar/launch.sh — как в оригинале.                    ║
# ║                                                                            ║
# ║  Три типа файлов (см. также modules/home/waybar.nix):                      ║
# ║    config.ini.pawlette — шаблон, симлинк в /nix/store (только чтение)      ║
# ║    config.ini          — результат генерации, РЕАЛЬНЫЙ записываемый файл,  ║
# ║                          иначе pawlette не сможет применить тему           ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  ...
}: let
  # ══ Фолбэк-палитра (Catppuccin Mocha) ═══════════════════════════════════
  # Нужна только до первого запуска pawlette: без неё в config.ini остались
  # бы литеральные {{color_bg}} и polybar не стартовал бы вообще.
  # ПОРЯДОК ВАЖЕН: ключи с фильтрами и более длинные — первыми, иначе
  # "{{color_text}}" съест префикс "{{color_text_muted}}".
  #
  # lighten-варианты посчитаны приблизительно (pawlette использует свой
  # алгоритм в HSL). На финальный вид это не влияет — после первой смены
  # темы pawlette перезапишет config.ini целиком.
  subst = builtins.replaceStrings
    [
      "{{color_magenta | lighten 10}}"
      "{{color_red | lighten 8}}"
      "{{color_text_muted}}"
      "{{color_primary}}"
      "{{color_magenta}}"
      "{{color_yellow}}"
      "{{color_green}}"
      "{{color_cyan}}"
      "{{color_blue}}"
      "{{color_text}}"
      "{{color_red}}"
      "{{color_bg}}"
      "{{ansi_color14}}"
      "{{ansi_color11}}"
      "{{ansi_color8}}"
    ]
    [
      "#e0bbff" # mauve, светлее
      "#ff9bb8" # red, светлее
      "#a6adc8" # subtext0
      "#b4befe" # lavender
      "#cba6f7" # mauve
      "#f9e2af" # yellow
      "#a6e3a1" # green
      "#94e2d5" # teal
      "#89b4fa" # blue
      "#cdd6f4" # text
      "#f38ba8" # red
      "#1e1e2e" # base
      "#74c7ec" # sapphire
      "#f9e2af" # peach -> yellow
      "#585b70" # surface2 (линия подчёркивания)
    ];

  configTemplate = ../../config/polybar/config.ini.pawlette;

  fallbackConfig =
    pkgs.writeText "polybar-config.ini"
    (subst (builtins.readFile configTemplate));

  polybarDir = "${config.xdg.configHome}/polybar";
in {
  home.packages = with pkgs; [
    polybar

    # ── Зависимости модулей бара ──
    jq # media.sh | jq -r '.text'
    playerctl # click-left/right на media
    blueman # blueman-manager по клику
    psmisc # killall в launch.sh
    xorg.xrandr # перебор мониторов в launch.sh

    # system-info.py (модули cpu/ram/gpu)
    (python3.withPackages (ps: [ps.psutil]))
  ];

  # ══ Шаблон: read-only симлинк — pawlette его только читает ═══════════════
  xdg.configFile."polybar/config.ini.pawlette".source = configTemplate;

  # ══ launch.sh ═══════════════════════════════════════════════════════════
  # toggle-bar.sh вызывает его по абсолютному пути:
  #   BAR_CMD["polybar"]="$HOME/.config/polybar/launch.sh"
  # поэтому файл обязан лежать именно здесь и быть исполняемым.
  xdg.configFile."polybar/launch.sh" = {
    source = ../../config/polybar/launch.sh;
    executable = true;
  };

  # ══ config.ini: реальный файл, а не симлинк ══════════════════════════════
  # Создаём только если его ещё нет — иначе затирали бы тему, которую
  # пользователь выбрал через pawlette (SUPER+T).
  home.activation.seedPolybarGenerated =
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ${lib.escapeShellArg polybarDir}
      if [ ! -e ${lib.escapeShellArg "${polybarDir}/config.ini"} ]; then
        run install -m 644 ${fallbackConfig} \
          ${lib.escapeShellArg "${polybarDir}/config.ini"}
      fi
    '';

  # TODO(шрифты): бар требует "JetBrainsMono Nerd Font" (font-0/font-1).
  #   Проверить, что nerd-fonts.jetbrains-mono есть в
  #   modules/nixos/system/fonts.nix, иначе вместо иконок будут квадраты.
  #
  # TODO(python): модули cpu/ram/gpu зовут `python`, а не `python3`.
  #   В NixOS алиаса `python` в PATH нет по умолчанию — то же замечание,
  #   что и для waybar. Проверить на живой системе.
}
