# ╔════════════════════════════════════════════════════════════════════════════╗
# ║  Picom — композитор для X11/bspwm-сессии (паритет с meowrch 4.1.1)         ║
# ║                                                                            ║
# ║  Источник: home/.config/bspwm/picom.conf                                   ║
# ║            home/.config/bspwm/default/autostart.sh (диспатч по GPU)        ║
# ║                                                                            ║
# ║  ВАЖНО: тут НЕТ services.picom!                                            ║
# ║  HM-модуль services.picom описывает настройки через Nix-опции и поднимает   ║
# ║  systemd-юнит. Нам нужен ровно оригинальный picom.conf (включая блок        ║
# ║  animations, которого в HM-опциях нет), плюс подбор флагов backend'а под    ║
# ║  конкретную видеокарту — этого HM тоже не умеет. Поэтому: файл как есть +   ║
# ║  скрипт запуска, который вызывается из bspwmrc.                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝
{
  config,
  pkgs,
  lib,
  ...
}: let
  picomConf = "${config.xdg.configHome}/bspwm/picom.conf";

  # gpu-detect-profile.sh лежит в scripts/ и линкуется в .config/meowrch/bin
  # (см. home.file.".config/meowrch/bin" в hosts/meowrch/home.nix).
  gpuProfile = "${config.xdg.configHome}/meowrch/bin/gpu-detect-profile.sh";
in {
  home.packages = [pkgs.picom];

  xdg.configFile."bspwm/picom.conf".source = ../../config/bspwm/picom.conf;

  # ══ Скрипт запуска ══════════════════════════════════════════════════════
  # 1:1 логика из default/autostart.sh. Отличия от оригинала:
  #   • picom вызывается по абсолютному пути в /nix/store, а не через PATH —
  #     bspwmrc запускается сессией, где PATH может быть ещё не наполнен;
  #   • [ -x ] вместо [[ -x ]]: оригинал использует bash-синтаксис под
  #     шебангом #!/bin/sh. На Arch это проходит (там /bin/sh -> bash),
  #     но полагаться на это не стоит.
  xdg.configFile."bspwm/picom-launch.sh" = {
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      # Сгенерировано modules/home/picom.nix — не редактировать вручную.

      PICOM=${lib.escapeShellArg "${pkgs.picom}/bin/picom"}
      CONF=${lib.escapeShellArg picomConf}
      GPU_PROFILE=${lib.escapeShellArg gpuProfile}

      if [ -x "$GPU_PROFILE" ]; then
        GPU_SETUP="$("$GPU_PROFILE")"
      else
        GPU_SETUP="unknown"
      fi

      case "$GPU_SETUP" in
        nvidia-only|hybrid-intel-nvidia)
          # NVIDIA: полная оптимизация
          "$PICOM" -b --backend glx --vsync \
            --use-damage \
            --glx-no-rebind-pixmap \
            --config "$CONF" &
          ;;
        amd-only|hybrid-amd-intel)
          # AMD/Mesa: без rebind-pixmap — на AMDGPU даёт артефакты
          "$PICOM" -b --backend glx --vsync \
            --use-damage \
            --config "$CONF" &
          ;;
        intel-only)
          # Intel iGPU: агрессивные флаги для Gen 9+.
          # Если на старой Intel полезут артефакты/битая прозрачность —
          # убрать --glx-no-rebind-pixmap или перейти на --backend xrender.
          "$PICOM" -b --backend glx --vsync \
            --use-damage \
            --glx-no-rebind-pixmap \
            --config "$CONF" &
          ;;
        nouveau-only|hybrid-intel-nouveau)
          # Nouveau: только glx + damage, без дополнений
          "$PICOM" -b --backend glx --vsync \
            --use-damage \
            --config "$CONF" &
          ;;
        *)
          # Фолбэк: безопасный xrender
          "$PICOM" -b --backend xrender --vsync \
            --config "$CONF" &
          ;;
      esac
    '';
  };

  # TODO(picom 12): в picom.conf остались опции, выпиленные из апстрима picom:
  #   xrender-sync (убрана в 8.x) и glx-copy-from-front (убрана в 12).
  #   picom их проигнорирует с warning'ом в лог, поведение не пострадает.
  #   Оставлены как есть, чтобы файл был байт-в-байт с оригиналом.
  #   Убирать — только вместе с апстримом, иначе разъедемся.
  #
  # TODO(проверить): блок animations = ( ... ) с triggers — это синтаксис
  #   picom 12+. Если в nixpkgs 25.11 приедет picom < 12, анимации отвалятся
  #   с ошибкой парсинга конфига.
}
