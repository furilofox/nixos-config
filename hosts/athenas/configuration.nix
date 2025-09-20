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
    ../../nixos/utils.nix
    ../../nixos/ssh.nix
    ../../nixos/networking.nix

    ../../homelab/services/homepage

    ./hardware-configuration.nix
    ./variables.nix
  ];

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
    interfaces.enp2s0 = {
      ipv4.addresses = [{
        address = "192.168.20.10";
        prefixLength = 24;
      }];
    };
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        53 # DNS TCP
      ];
      allowedUDPPorts = [
        53 # DNS UDP
      ];
    };
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };

  # DNS Server Configuration (dnsmasq)
  /*
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
  */

  # Caddy reverse proxy
  /*
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
  */

  # Don't touch this
  system.stateVersion = "24.11";
}
