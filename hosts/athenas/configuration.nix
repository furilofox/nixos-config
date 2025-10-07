{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/locale.nix
    ../../nixos/utils.nix
    ../../nixos/ssh.nix
    ../../nixos/networking.nix

    ../../homelab

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
      cloudflareApiToken = "censored"; # TODO: DON'T PUSH!!!!!!!!!!!!!
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
  system.stateVersion = "24.11";
}
