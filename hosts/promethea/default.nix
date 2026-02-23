# Promethea - Laptop
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

  hostname = "promethea";
  username = "fabian";

  desktop.monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refresh = 60;
      scale = 1.0;
    }
  ];

  hardware.sensor.iio.enable = true;
  secrets.enable = true;
  services.power-profiles-daemon.enable = true;

  home-manager.users.${config.username} = import ./home.nix;

  system.stateVersion = "24.11";
}
