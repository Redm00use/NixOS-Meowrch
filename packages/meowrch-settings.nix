# ── meowrch-settings ─────────────────────────────────────────
# System optimization settings: sysctl, udev rules, modprobe,
# systemd configs, zram, earlyoom integration.
# Source: https://github.com/meowrch/meowrch-settings

{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "meowrch-settings";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "meowrch-settings";
    rev = "v${version}";
    hash = "sha256-5HSlpWRP1j+oB3AenxZrV3W/i0TxIom4qevkTxD/1ew=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    if [ -d usr ]; then
      mkdir -p $out/bin $out/share $out/lib
      
      # Copy binaries
      if [ -d usr/bin ]; then
        cp -r usr/bin/* $out/bin/
        chmod +x $out/bin/*
      fi
      
      # Copy share data
      if [ -d usr/share ]; then
        cp -r usr/share/* $out/share/
      fi
      
      # Copy lib data
      if [ -d usr/lib ]; then
        cp -r usr/lib/* $out/lib/
      fi
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "System optimization settings for Meowrch distribution";
    homepage = "https://github.com/meowrch/meowrch-settings";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ "Redm00us" ];
  };
}