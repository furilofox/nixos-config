let
  secrets = import ./secrets.nix;
in {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixos

    ../../homelab

    ../../homelab/gameserver/necesse.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  system = {
    audio.enable = false;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  homelab = {
    enable = true;
    user = "homelab";
    group = "homelab";
    baseDomain = "furilo.me";

    homepage = {
      enable = true;
    };

    adguard = {
      enable = true;
      port = 3000;
      dnsPort = 53;
    };

    caddy = {
      enable = true;
      domain = "furilo.me";
      cloudflareApiToken = secrets.cloudflareApiToken;
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

  services.necesse-server = {
    enable = true;
    worldName = "IrgendEineWelt"; # Will be created if it doesn't exist
    slots = 20;
    openFirewall = true;
  };

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
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        53 # DNS TCP
      ];
      allowedUDPPorts = [
        53 # DNS UDP
        67 # DHCP
        68 # DHCP
      ];
    };
  };

  # Don't touch this
  system.stateVersion = "25.05";
}
