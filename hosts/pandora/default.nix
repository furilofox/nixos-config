# Pandora - Desktop
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/desktop.nix
    ./hardware-configuration.nix
  ];

  hostname = "pandora";
  username = "fabian";

  hardware.amd = {
    enable = true;
    freesync = true;
  };

  desktop.niri.monitors = [
    {
      name = "HDMI-A-2";
      width = 1920;
      height = 1200;
      refresh = 60;
      position = "0,0";
    }
    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      refresh = 144;
      position = "1920,-200";
    }
  ];

  secrets.enable = true;
  services.pcscd.enable = true;

  networking = {
    defaultGateway = "192.168.20.1";
    nameservers = ["192.168.20.10" "1.1.1.1"];
    interfaces.enp42s0 = {
      ipv4.addresses = [
        {
          address = "192.168.20.21";
          prefixLength = 24;
        }
      ];
    };
  };

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  home-manager.users.${config.username} = import ./home.nix;

  system.stateVersion = "25.05";
}
