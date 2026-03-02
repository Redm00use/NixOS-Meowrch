{ config, pkgs, lib, meowrchUser, ... }:

{
  # Security Configuration
  security = {
    # Enable polkit for privilege escalation
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (
                subject.isInGroup("users")
                    && (
                        action.id == "org.freedesktop.login1.reboot" ||
                        action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                        action.id == "org.freedesktop.login1.power-off" ||
                        action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
                        action.id == "org.freedesktop.login1.suspend" ||
                        action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
                        action.id == "org.freedesktop.login1.hibernate" ||
                        action.id == "org.freedesktop.login1.hibernate-multiple-sessions"
                    )
                )
            {
                return polkit.Result.YES;
            }
        });

        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.NetworkManager.settings.modify.system" &&
                subject.isInGroup("networkmanager")) {
                return polkit.Result.YES;
            }
        });

        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
                subject.isInGroup("users")) {
                return polkit.Result.YES;
            }
        });
      '';
    };

    # RTKit for real-time scheduling
    rtkit.enable = true;

    # PAM configuration
    pam = {
      loginLimits = [
        {
          domain = "@users";
          type = "soft";
          item = "nofile";
          value = "65536";
        }
        {
          domain = "@users";
          type = "hard";
          item = "nofile";
          value = "65536";
        }
        {
          domain = "@audio";
          type = "-";
          item = "rtprio";
          value = "99";
        }
        {
          domain = "@audio";
          type = "-";
          item = "memlock";
          value = "unlimited";
        }
        {
          domain = "@video";
          type = "-";
          item = "rtprio";
          value = "99";
        }
      ];

      services = {
        login.enableGnomeKeyring = true;
        passwd.enableGnomeKeyring = true;
        gdm.enableGnomeKeyring = true;
        sddm.enableGnomeKeyring = true;

        # Enable fingerprint authentication if available
        login.fprintAuth = false;
        sudo.fprintAuth = false;

        # Security settings
        su.requireWheel = true;
      };
    };

    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = false;

      extraRules = [
        {
          commands = [
            {
              command = "${pkgs.systemd}/bin/systemctl suspend";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl reboot";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl poweroff";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl restart bluetooth";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl restart NetworkManager";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.brightnessctl}/bin/brightnessctl";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
        {
          commands = [
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild boot";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
        {
          users = [ meowrchUser ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults insults
        Defaults lecture=never
        Defaults pwfeedback
      '';
    };

    # User namespaces (security vs compatibility trade-off)
    allowUserNamespaces = true;
  };

  # Security packages
  environment.systemPackages = with pkgs; [
    # Authentication
    polkit_gnome
    gnome-keyring
    libsecret

    # Security tools (fail2ban and clamav may not be available)
    keepassxc

    # Encryption tools
    gnupg
    openssl

    # System monitoring
    lynis

    # Network security
    nmap
    wireshark
  ];

  # Kernel security parameters
  boot.kernel.sysctl = {
    # Disable NMI watchdog for performance
    "kernel.nmi_watchdog" = 0;

    # Kernel pointer restriction
    "kernel.kptr_restrict" = 2;

    # Restrict access to kernel logs
    "kernel.printk" = "3 3 3 3";

    # Restrict kernel log access
    "kernel.dmesg_restrict" = 1;

    # Enable ASLR
    "kernel.randomize_va_space" = 2;

    # Restrict ptrace
    "kernel.yama.ptrace_scope" = 1;

    # Disable kexec
    "kernel.kexec_load_disabled" = 1;

    # Disable user namespaces for unprivileged users
    "kernel.unprivileged_userns_clone" = 1;

    # Network security
    "net.core.bpf_jit_harden" = 2;

    # Memory protection
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;

    # Filesystem security
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
  };

  # Blacklist kernel modules
  boot.blacklistedKernelModules = [
    # Uncommon network protocols
    "dccp"
    "sctp"
    "rds"
    "tipc"

    # Rare filesystems (squashfs НЕ блокируем — NixOS использует его для nix store!)
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "udf"

    # Firewire (can be used for DMA attacks)
    "firewire-core"
    "firewire-ohci"
    "firewire-sbp2"

    # Thunderbolt (can be used for DMA attacks)
    "thunderbolt"

    # USB storage (uncomment if you want to disable USB storage)
    # "usb-storage"

    # Webcam (uncomment if you want to disable webcam)
    # "uvcvideo"
  ];

  # Services for security
  services = {
    # GNOME Keyring for credential storage (Zed IDE, etc)
    gnome.gnome-keyring.enable = true;

    # UDisks2 for secure disk management
    udisks2.enable = true;
  };

  # User security groups
  users.groups = {
    secure = {};
  };

  # Add security-related groups (user groups defined in main configuration.nix)

  # SystemD security services (polkit agent is configured in main configuration.nix)

  # Security environment variables
  environment.sessionVariables = {
    # Harden memory allocator
    MALLOC_CHECK_ = "2";
    MALLOC_PERTURB_ = "1";

    # Browser security
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
  };

  # File permissions and security
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
    "d /var/tmp 1777 root root - -"
    "d /home 0755 root root - -"
    "z /etc/shadow 0600 root root - -"
    "z /etc/passwd 0644 root root - -"
    "z /etc/group 0644 root root - -"
  ];
}
