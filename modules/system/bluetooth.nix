{ config, pkgs, lib, ... }:

{
  # Bluetooth Configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;

    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        KernelExperimental = true;
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
        FastConnectable = true;
      };

      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 7;
        ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
      };

      LE = {
        MinConnectionInterval = 7;
        MaxConnectionInterval = 9;
        ConnectionLatency = 0;
        ConnectionSupervisionTimeout = 720;
        Autoconnect = true;
      };

      GATT = {
        ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
        AutoEnable = true;
      };
    };
  };

  # Bluetooth services
  services = {
    # Bluetooth manager
    blueman.enable = true;

    # D-Bus configuration for Bluetooth
    dbus.packages = with pkgs; [ bluez blueman ];

    # udev rules for Bluetooth devices
    udev.packages = with pkgs; [ bluez ];
  };

  # Bluetooth packages
  environment.systemPackages = with pkgs; [
    # Bluetooth utilities
    bluez
    bluez-tools
    bluez-alsa
    blueman

    # Audio over Bluetooth (handled by PipeWire)

    # GUI managers
    blueberry

    # Command line tools
    bluetuith

    # Debugging tools
    # rfkill  # Not available as separate package

    # Audio testing
    # bluetoothctl  # Included in bluez package
  ];

  # User permissions for Bluetooth (defined in main configuration.nix)

  # Systemd services for Bluetooth
  systemd.services.bluetooth = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.bluez}/libexec/bluetooth/bluetoothd --noplugin=sap"
      ];
    };
  };

  # Bluetooth audio support is handled by PipeWire
  # PulseAudio modules removed to avoid conflicts with PipeWire

  # PipeWire Bluetooth configuration
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
        ["bluez5.codecs"] = "[ sbc sbc_xq aac ldac aptx aptx_hd aptx_ll aptx_ll_duplex faststream faststream_duplex ]",
        ["bluez5.default.rate"] = 48000,
        ["bluez5.default.channels"] = 2,
      }
    '')
  ];

  # Bluetooth kernel modules
  boot.kernelModules = [
    "bluetooth"
    "btusb"
    "rfcomm"
    "bnep"
    "btrtl"
    "btbcm"
    "btintel"
  ];

  # Bluetooth firmware
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  # Power management for Bluetooth
  powerManagement.enable = true;

  # udev rules for Bluetooth power management
  services.udev.extraRules = ''
    # Disable USB autosuspend for Bluetooth devices
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", TEST=="power/control", ATTR{power/control}="on"

    # Bluetooth device permissions
    KERNEL=="rfkill", SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", TAG+="uaccess"

    # Allow users in bluetooth group to control Bluetooth adapters
    SUBSYSTEM=="bluetooth", TAG+="uaccess"
    KERNEL=="hci[0-9]*", TAG+="uaccess"
  '';

  # Bluetooth security settings
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.passwd.enableGnomeKeyring = true;

  # Auto-start Bluetooth manager
  systemd.user.services.blueman-applet = {
    description = "Blueman applet";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Environment variables for Bluetooth
  environment.sessionVariables = {
    # Bluetooth audio quality
    BLUETOOTH_A2DP_CODEC = "aptx";
    BLUETOOTH_A2DP_BITPOOL = "53";
  };

  # Bluetooth configuration files
  environment.etc = {
    "bluetooth/audio.conf" = lib.mkForce {
      text = ''
        [General]
        Enable=Source,Sink,Media,Socket
        Disable=Headset

        [A2DP]
        SBCFreq=44100,48000
        SBCXQ=true

        [AVRCP]
        Class=0x000100
        Title=%s
        Artist=%s
        Album=%s
        Genre=%s
        NumberOfTracks=%s
        TrackNumber=%s
        TrackDuration=%s
      '';
    };

    "bluetooth/input.conf" = lib.mkForce {
      text = ''
        [General]
        UserspaceHID=true
        ClassicBondedOnly=false
        LEAutoConnect=true
      '';
    };

    "bluetooth/network.conf" = lib.mkForce {
      text = ''
        [General]
        DisableSecurity=false
      '';
    };
  };

  # Bluetooth mesh support
  boot.kernelParams = [
    "bluetooth.disable_ertm=1"
    "bluetooth.disable_esco=1"
  ];

  # Auto-start Bluetooth on boot
  systemd.user.services.bluetooth-autostart = {
    description = "Auto-start Bluetooth";
    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "bluetooth-autostart" ''
        sleep 3
        ${pkgs.bluez}/bin/bluetoothctl power on
      '';
    };
  };

  # Bluetooth troubleshooting tools are included above
}
