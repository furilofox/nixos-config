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

    ../../nixos/bluetooth.nix
    ../../nixos/ram-swap.nix

    ../../nixos/1pass.nix
    ../../nixos/utils.nix
    ../../nixos/ssh.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Don't touch this
  system.stateVersion = "24.11";
}
