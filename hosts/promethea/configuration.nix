{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/common
    ../../nixos/hardware/intel.nix
    ../../nixos/hardware/touchpad.nix
    ../../nixos/hardware/fprint.nix

    ../../nixos/desktop/gnome

    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix
    ../../nixos/miracast.nix
    ../../nixos/gaming.nix
    ../../nixos/docker.nix

    ../../nixos/fonts.nix

    ../../nixos/1pass.nix
    ../../nixos/utils.nix

    ../../server/node-red
    ../../server/home-assistant
    ../../server/n8n
    ../../server/homepage

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Orientation & other Sensors
  hardware.sensor.iio.enable = true;

  environment.systemPackages = with pkgs; [devenv unixtools.netstat];

  # Don't touch this
  system.stateVersion = "24.11";
}
