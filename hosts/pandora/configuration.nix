{
  config,
  pkgs,
  ...
}: {
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

  boot.kernelParams = [
    "video=DP-2:1920x1200@60"
    "video=HDMI-A-2:2560x1440@144"
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  environment.systemPackages = with pkgs; [devenv unixtools.netstat];

  # Don't touch this
  system.stateVersion = "25.05";
}
