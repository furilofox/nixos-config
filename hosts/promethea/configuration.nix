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

    ../../nixos/1pass.nix
    ../../nixos/audio.nix
    ../../nixos/printing.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/gnome.nix
    ../../nixos/utils.nix

    ../../nixos/hardware/touchpad.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.11";
}
