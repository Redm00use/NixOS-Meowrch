{ config, pkgs, lib, ... }:

{
  # Networking Configuration
  networking = {
    hostName = "meowrch";

    # Enable NetworkManager
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      ethernet.macAddress = "preserve";
      wifi.macAddress = "preserve";

      # DNS configuration
      dns = "systemd-resolved";

      # Connection sharing
      unmanaged = [
        "*,except:type:wifi,except:type:ethernet"
      ];
    };

    # Wireless configuration
    wireless = {
      enable = false; # We use NetworkManager instead
    };

    # Enable systemd-resolved
    nameservers = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" "8.8.4.4" ];

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
        80    # HTTP
        443   # HTTPS
        8080  # Alternative HTTP
      ];
      allowedUDPPorts = [
        53    # DNS
        67    # DHCP
        68    # DHCP
      ];

      # Allow specific applications
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
      ];

      # Disable ping
      allowPing = true;

      # Log dropped packets
      logReversePathDrops = true;

      # Enable connection tracking helpers
      connectionTrackingModules = [ "ftp" "irc" "sane" ];

      # Custom rules
      extraCommands = ''
        # Allow loopback
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT

        # Allow established and related connections
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # Allow mDNS
        iptables -A INPUT -p udp --dport 5353 -j ACCEPT
      '';
    };

    # IPv6 configuration
    enableIPv6 = true;

    # Proxy configuration
    proxy = {
      default = null;
      noProxy = "127.0.0.1,localhost,internal.domain";
    };

    # Network bridge for VMs
    bridges = {};

    # DHCP configuration
    dhcpcd.enable = false; # We use NetworkManager

    # Static network configuration (commented out - using DHCP via NetworkManager)
    # interfaces = {
    #   enp0s3 = {
    #     ipv4.addresses = [{
    #       address = "192.168.1.100";
    #       prefixLength = 24;
    #     }];
    #   };
    # };
    # defaultGateway = "192.168.1.1";
  };

  # Network services
  services = {
    # Network Manager OpenVPN support
    # networkmanager-openvpn.enable = true; # This option doesn't exist in services

    # Resolved for DNS
    resolved = {
      enable = true;
      domains = [ "~." ];
      fallbackDns = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" "8.8.4.4" ];
      dnssec = lib.mkDefault "true";
      extraConfig = ''
        DNS=1.1.1.1 8.8.8.8 1.0.0.1 8.8.4.4
        DNSOverTLS=yes
        MulticastDNS=yes
        LLMNR=yes
        Cache=yes
        CacheFromLocalhost=yes
      '';
    };

    # Avahi for mDNS/Bonjour
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      };
    };

    # SSH configuration
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        PrintMotd = false;
      };
      openFirewall = true;
    };

    # Network Time Protocol
    ntp.enable = false; # We use systemd-timesyncd instead
    timesyncd = {
      enable = true;
      servers = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };
  };

  # Network packages
  environment.systemPackages = with pkgs; [
    # Network utilities
    networkmanager
    networkmanagerapplet
    networkmanager-openvpn

    # Command line tools
    wget
    curl
    dig
    nmap
    netcat-gnu
    traceroute
    whois
    iperf3

    # Wireless tools
    iw
    wpa_supplicant
    wirelesstools

    # VPN clients
    openvpn
    wireguard-tools

    # Network monitoring
    nethogs
    iftop
    bandwhich

    # Firewall management (NixOS uses built-in firewall)
    # ufw  # Not available in NixOS

    # mDNS utilities
    avahi
  ];

  # Users in network groups (defined in main configuration.nix)

  # Network optimization
  boot.kernel.sysctl = {
    # TCP optimization
    "net.core.rmem_max" = 268435456;
    "net.core.wmem_max" = 268435456;
    "net.ipv4.tcp_rmem" = "4096 65536 268435456";
    "net.ipv4.tcp_wmem" = "4096 65536 268435456";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Network security
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # IPv6 security
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
  };

  # Systemd network wait online (disable to speed up boot)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Environment variables for networking
  environment.sessionVariables = {
    # Set default browser for network applications
    BROWSER = "firefox";
  };
}
