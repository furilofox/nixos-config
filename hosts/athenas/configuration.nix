{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/locale.nix
    ../../nixos/hardware/intel.nix
    ../../nixos/ram-swap.nix
    ../../nixos/utils.nix
    ../../nixos/ssh.nix

    ../../homelab/services/homepage

    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Prevent Suspend when lid closed
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  # Screen off after 30 Seconds
  boot.kernelParams = ["consoleblank=30"];

  homelab = {
    services = {
      homepage = {
        enable = true;
      };
    };
  };

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "homelab-server";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        53 # DNS TCP
      ];
      allowedUDPPorts = [
        53 # DNS UDP
      ];
    };
  };

  # DNS Server Configuration (dnsmasq)
  services.dnsmasq = {
    enable = true;
    settings = {
      bind-interfaces = true;
      listen-address = [
        "127.0.0.1"
        "192.168.225.123"
      ];

      # Upstream DNS servers (Cloudflare)
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      # Local domain resolution
      address = [
        "/home.local/192.168.225.123"
      ];

      # Cache settings
      cache-size = 1000;

      # Don't read /etc/hosts
      no-hosts = true;

      # Don't read /etc/resolv.conf
      no-resolv = true;

      # Log queries for debugging
      log-queries = true;
    };
  };

  # Caddy reverse proxy
  services.caddy = {
    enable = true;
    virtualHosts = {
      "homepage.home.local" = {
        extraConfig = ''
          reverse_proxy localhost:8082
          tls internal
        '';
      };

      # Add more services here as needed
      # "nextcloud.home.local" = {
      #   extraConfig = ''
      #     reverse_proxy localhost:8080
      #     tls internal
      #   '';
      # };
    };

    # Global config to allow self-signed certificates
    globalConfig = ''
      auto_https disable_redirects
    '';
  };

  # Don't touch this
  system.stateVersion = "24.11";
}
