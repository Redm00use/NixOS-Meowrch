{ config, pkgs, lib, ... }:

{
  # System Services Configuration
  # System Services Configuration
  services = {
    # Display Manager (SDDM configuration moved to desktop module)
    # displayManager configuration is handled in modules/desktop/sddm.nix

    # Desktop Portal
    xserver = {
      enable = false; # We use Wayland
      excludePackages = with pkgs; [ xterm ];
    };

    # Printing and CUPS
    printing = {
      enable = true;
      browsing = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      defaultShared = false;
      openFirewall = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        epson-escpr
        canon-cups-ufr2
      ];
    };

    # Scanner support (moved to hardware.sane in a hardware module)
    # sane = {
    #   enable = true;
    #   extraBackends = with pkgs; [
    #     hplip
    #     epkowa
    #     sane-airscan
    #   ];
    # };

    # Time synchronization
    timesyncd.enable = true;

    # Power management (TLP - works reliably in NixOS)
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        ENERGY_PERF_POLICY_ON_AC = "performance";
        ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };

    # Power profiles daemon (alternative power management - disabled in favor of TLP)
    # power-profiles-daemon.enable = false;

    # UPower for battery information
    upower.enable = true;

    # Firmware updates
    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };

    # Flatpak support
    flatpak.enable = true;

    # GVFS for file manager functionality
    gvfs.enable = true;

    # Tumbler for thumbnails
    tumbler.enable = true;

    # Location services
    geoclue2.enable = true;

    # Thermald for thermal management (Intel)
    thermald.enable = lib.mkIf (config.hardware.cpu.intel.updateMicrocode or false) true;

    # Auto CPU frequency scaling (not available in standard NixOS)
    # auto-cpufreq = {
    #   enable = false; # Can conflict with TLP
    #   settings = {
    #     battery = {
    #       governor = "powersave";
    #       turbo = "never";
    #     };
    #     charger = {
    #       governor = "performance";
    #       turbo = "auto";
    #     };
    #   };
    # };

    # D-Bus
    dbus = {
      enable = true;
      packages = with pkgs; [
        gcr
        gnome-settings-daemon
      ];
    };

    # udev rules and services
    udev = {
      enable = true;
      packages = with pkgs; [
        gnome-settings-daemon
        android-udev-rules
      ];

      extraRules = ''
        # USB device rules
        SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", MODE="0664", GROUP="users"

        # Android devices
        SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="users"

        # Gaming controllers
        KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="*", MODE="0666"
        KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="*", MODE="0666"

        # Brightness control
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"

        # Input devices
        SUBSYSTEM=="input", GROUP="input", MODE="0664"

        # Storage devices
        SUBSYSTEM=="block", TAG+="systemd"
      '';
    };

    # Logind configuration (logind is always enabled in NixOS)
    # Use systemd.services.systemd-logind.serviceConfig or boot.kernelParams for power management

    # Locate database
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "02:15";
    };

    # System cleanup
    journald = {
      extraConfig = ''
        SystemMaxUse=500M
        SystemMaxFileSize=50M
        MaxRetentionSec=1week
        Compress=yes
        ForwardToSyslog=no
      '';
    };

    # Automatic garbage collection
    # System cleanup is handled by global nix configuration

    # Hardware monitoring
    smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        x11.enable = true;
        wall.enable = false;
        mail.enable = false;
      };
    };

    # Zram for compressed swap (using correct NixOS 25.05 syntax)
    # Note: zram-generator service doesn't exist, use boot.zram instead
    # This is configured in main configuration.nix as:
    # zramSwap = {
    #   enable = true;
    #   algorithm = "zstd";
    #   memoryPercent = 50;
    # };

    # Earlyoom for OOM prevention (using systemd service)
    # Note: services.earlyoom may not be available, configure via systemd

    # TRIM support for SSDs
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Automatic system updates (NixOS uses nix.gc and system.autoUpgrade)
    # Configure in main configuration.nix with system.autoUpgrade options



    # Avahi for network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    # UDisks2 for removable media
    udisks2.enable = true;

    # Polkit for privilege escalation (configured in security.nix)
    # polkit.enable = true;

    # GNOME Keyring (configured in security.nix)
    # gnome.gnome-keyring.enable = true;

    # Hardware acceleration is now managed in graphics.nix

    # Bluetooth
    blueman.enable = true;



    # Preload for faster application startup (not available in NixOS)
    # preload = {
    #   enable = false; # Can use significant RAM
    # };

    # System profiler (sysprof not available as service)
    # sysprof.enable = false;

    # AppArmor (configured in security.nix)
    # apparmor = {
    #   enable = false;
    #   killUnconfinedConfinables = false;
    # };



    # Steam hardware support is enabled via programs.steam in graphics module

    # USB automounting (devmon not available, using udisks2)
    # devmon.enable = true;

    # Resolved for DNS
    resolved = {
      enable = true;
      domains = [ "~." ];
      fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
      dnssec = "allow-downgrade";
    };
  };

  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      hyprland = {
        default = [ "gtk" ];
      };
    };
  };

  # Additional system-wide services via systemd
  systemd.services = {
    # EarlyOOM service (manual configuration for NixOS 25.05)
    earlyoom = {
      description = "Early OOM Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.earlyoom}/bin/earlyoom -g --avoid '^(systemd|kernel)$$' --prefer '^(Web Content|firefox|chrome)$$' -m 5 -s 5";
        Restart = "always";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Custom cleanup service
    meowrch-cleanup = {
      description = "Meowrch system cleanup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "meowrch-cleanup" ''
          # Clean package cache
          ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d

          # Clean journal logs
          ${pkgs.systemd}/bin/journalctl --vacuum-time=7d

          # Clean temporary files
          ${pkgs.findutils}/bin/find /tmp -type f -atime +3 -delete || true
          ${pkgs.findutils}/bin/find /var/tmp -type f -atime +7 -delete || true
        '';
      };
      startAt = "weekly";
    };

    # Fix permissions service
    meowrch-fix-permissions = {
      description = "Fix Meowrch permissions";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "fix-permissions" ''
          # Fix audio group permissions
          ${pkgs.coreutils}/bin/chmod 664 /dev/snd/* || true

          # Fix video group permissions
          ${pkgs.coreutils}/bin/chmod 664 /dev/dri/* || true

          # Fix input group permissions
          ${pkgs.coreutils}/bin/chmod 664 /dev/input/* || true
        '';
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udev-settle.service" ];
    };
  };

  # Systemd user services
  systemd.user.services = {
    # User cleanup service
    meowrch-user-cleanup = {
      description = "Meowrch user cleanup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "user-cleanup" ''
          # Clean user cache
          ${pkgs.findutils}/bin/find $HOME/.cache -type f -atime +7 -delete || true

          # Clean browser cache (if too large)
          if [ -d "$HOME/.cache/mozilla" ]; then
            ${pkgs.coreutils}/bin/du -sh "$HOME/.cache/mozilla" | ${pkgs.gawk}/bin/awk '$1 ~ /G/ && $1 > 1 {exit 1}'
            if [ $? -ne 0 ]; then
              ${pkgs.findutils}/bin/find "$HOME/.cache/mozilla" -type f -atime +3 -delete || true
            fi
          fi
        '';
      };
      startAt = "daily";
    };
  };

  # System timer for maintenance
  systemd.timers = {
    meowrch-maintenance = {
      description = "Meowrch system maintenance timer";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      wantedBy = [ "timers.target" ];
    };
  };

  # Enable important services by default
  systemd.targets.multi-user.wants = [
    "meowrch-fix-permissions.service"
  ];
}
