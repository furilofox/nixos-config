# Athenas - Server Machine
# Uses server profile with homelab services
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Server profile
    ../../profiles/server.nix

    # Homelab services (existing)
    ../../homelab
    ../../homelab/gameserver/necesse.nix

    # Hardware configuration
    ./hardware-configuration.nix
  ];

  # Host identification
  hostname = "athenas";
  username = "fabian";

  # Boot configuration (override default)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Secrets configuration
  secrets = {
    enable = true;
    # file = "${inputs.my-secrets}/secrets.nix";  # Uncomment when private repo is ready
  };

  # Homelab configuration
  homelab = {
    enable = true;
    user = "homelab";
    group = "homelab";
    baseDomain = "furilo.me";

    homepage.enable = true;

    adguard = {
      enable = true;
      port = 3000;
      dnsPort = 53;
    };

    caddy = {
      enable = true;
      domain = "furilo.me";
      # cloudflareApiToken = config.sops.secrets.cloudflare_api_token.path;  # Use sops secret
      routes = {
        homepage = {
          subdomain = "home";
          upstream = "http://localhost:8082";
        };
        adguard = {
          subdomain = "adguard";
          upstream = "http://localhost:3000";
        };
      };
    };
  };

  # Necesse game server
  services.necesse-server = {
    enable = true;
    worldName = "IrgendEineWelt";
    slots = 20;
    openFirewall = true;
  };

  # Network configuration
  networking = {
    nameservers = ["127.0.0.1"];
    defaultGateway = "192.168.20.1";
    interfaces.enp2s0 = {
      ipv4.addresses = [
        {
          address = "192.168.20.10";
          prefixLength = 24;
        }
      ];
    };
    firewall = {
      allowedTCPPorts = [80 443 53];
      allowedUDPPorts = [53 67 68];
    };
  };

  system.stateVersion = "25.05";
}
