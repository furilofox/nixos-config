{config, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/common
    ../../nixos/hardware/amd.nix

    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/gnome.nix
    ../../nixos/utils.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "25.05";
}
