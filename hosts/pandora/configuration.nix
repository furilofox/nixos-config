{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/locale.nix
    ../../nixos/networking.nix
    ../../nixos/hardware/amd.nix

    ../../nixos/desktop/gnome

    ../../nixos/services/mullvad.nix

    ../../nixos/audio.nix
    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix

    ../../nixos/fonts.nix

    ../../nixos/gaming.nix
    ../../nixos/1pass.nix
    ../../nixos/utils.nix
    ../../nixos/docker.nix
    ../../nixos/home-manager.nix
    ../../nixos/ssh.nix

    ../../homelab

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  environment.systemPackages = with pkgs; [devenv unixtools.netstat];

  # Test Local AI
  /* services = {
    ollama = {
      enable = true;
      acceleration = "rocm";
      port = 11434;
      openFirewall = true;
    };
    open-webui = {
      enable = true;
      port = 11456;
      openFirewall = true;
      host = "0.0.0.0";
    };
  }; */

  # Don't touch this
  system.stateVersion = "25.05";
}
