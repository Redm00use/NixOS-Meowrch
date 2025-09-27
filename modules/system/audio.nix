{ config, pkgs, lib, ... }:
#
# Audio stack configuration (PipeWire + WirePlumber) with sane low‑latency
# defaults. Bluetooth is managed in a dedicated bluetooth module. Kept intentionally concise;
# firmware enabling is handled globally (do NOT add enableAllFirmware here).
#
# Safe to import on any host.
{
  ############################################
  # PipeWire / WirePlumber
  ############################################
  services.pipewire = {
    enable = true;

    # ALSA compatibility (32‑bit for games / legacy)
    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;   # PulseAudio replacement layer
    jack.enable = true;    # JACK compatibility
    wireplumber.enable = true;
  };

  ############################################
  # Disable legacy PulseAudio daemon
  ############################################
  services.pulseaudio.enable = false;

  ############################################
  # Bluetooth (A2DP / headset) integration
  ############################################
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Extended Bluetooth profiles (modern BlueZ auto‑detects most)
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  ############################################
  # Packages (userland tools)
  ############################################
  environment.systemPackages = with pkgs; [
    pavucontrol
    pamixer
    playerctl
    wireplumber
    # Optional production tools (uncomment if needed)
    # audacity
    # ardour
  ];

  ############################################
  # Udev rules (permissions)
  ############################################
  services.udev.extraRules = ''
    SUBSYSTEM=="sound", GROUP="audio", MODE="0664"
    KERNEL=="controlC[0-9]*", GROUP="audio", MODE="0664"
  '';

  ############################################
  # Low latency tuning (PipeWire)
  ############################################
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };

  services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
    context.modules = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          pulse.min.req = "32/48000";
          pulse.default.req = "32/48000";
          pulse.max.req = "32/48000";
          pulse.min.quantum = "32/48000";
          pulse.max.quantum = "32/48000";
        };
      }
    ];
    stream.properties = {
      node.latency = "32/48000";
      resample.quality = 1;
    };
  };

  ############################################
  # Kernel / driver tweaks (kept minimal)
  ############################################
  boot.kernelModules = [
    "snd-seq"
    "snd-rawmidi"
  ];

  boot.kernelParams = [
    # Keep HDA powered (avoid wake delay / pop on some codecs)
    "snd_hda_intel.power_save=0"
    "snd_hda_intel.power_save_controller=N"
  ];

  ############################################
  # PAM limits for real‑time & lockable memory
  ############################################
  security.pam.loginLimits = [
    { domain = "@audio"; type = "-"; item = "rtprio";  value = "95"; }
    { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];

  ############################################
  # Helpful latency hint (non‑critical)
  ############################################
  environment.sessionVariables.PIPEWIRE_LATENCY = "32/48000";
}
