# Mewline — панель по умолчанию в meowrch 4.1.1 для ОБЕИХ сессий.
#
# Реестр баров задан в scripts/toggle-bar.sh:
#   WM_BARS["hyprland"] = "mewline waybar"
#   WM_BARS["bspwm"]    = "mewline-bspwm polybar"
#
# Первый в списке — бар по умолчанию, поэтому mewline активен и в Hyprland,
# и в bspwm. waybar / polybar — альтернативы по SUPER+SHIFT+B.
#
# Запуск различается по сессиям:
#   Hyprland — uwsm-launcher.sh -t service -s s mewline  (сессией владеет uwsm)
#   bspwm    — mewline напрямую, без uwsm
#
# ВНИМАНИЕ: модуль намеренно НЕ определяет systemd.user.services.mewline.
# Жизненным циклом бара владеет toggle-bar.sh через pgrep -x / pkill -x.
# Если держать mewline systemd-сервисом с Restart=, то SUPER+B не сможет его
# скрыть (systemd тут же поднимет процесс), а SUPER+SHIFT+B покажет два бара
# одновременно. В hosts/meowrch/home.nix такой сервис пока есть — его нужно
# убрать при подключении этого модуля (либо осознанно отказаться от смены бара).

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mewline
    # fabric-cli нужен для dynamic-island-open (бинды super+alt+* в сессии bspwm)
    fabric-cli

    # OCR-модуль сконфигурирован на default_lang = "rus+eng",
    # поэтому нужны языковые данные обоих языков.
    (tesseract.override { enableLanguages = [ "eng" "rus" ]; })
  ];

  # Линкуем ТОЛЬКО один файл внутри ~/.config/mewline, а не весь каталог:
  # pawlette кладёт темы в ~/.config/mewline/themes/, и если сделать симлинком
  # весь каталог, запись тем упадёт с Read-only file system.
  xdg.configFile."mewline/config.json".source = ../../config/mewline/config.json;

  # TODO(паритет): конфиг ссылается на два внешних ресурса:
  #   1. ~/.local/share/meowrch/assets/default-album-logo.png — заглушка обложки
  #      в музыкальном виджете; в форке ещё не разворачивается.
  #   2. wayland_method = "awww" — смена обоев в Wayland. awww пока не упакован
  #      (в upstream 4.x он заменил swww), без него выбор обоев из dynamic-island
  #      не сработает. См. docs/UPSTREAM-PARITY.md.
}
