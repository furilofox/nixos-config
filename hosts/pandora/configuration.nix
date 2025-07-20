{config,pkgs, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/common
    ../../nixos/hardware/amd.nix

    ../../nixos/desktop/gnome

    ../../nixos/audio.nix
    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix

    ../../nixos/fonts.nix

    ../../nixos/gaming.nix
    ../../nixos/1pass.nix
    ../../nixos/utils.nix
    ../../nixos/docker.nix

    ../../server/home-assistant
    ../../server/n8n

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  environment.systemPackages = with pkgs; [devenv];

  # Don't touch this
  system.stateVersion = "25.05";
}
