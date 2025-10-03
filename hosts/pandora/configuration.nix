{
  config,
  pkgs,
  inputs,
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

    ../../nixos/desktop/hyprland

    ../../nixos/services/mullvad.nix
    ../../nixos/services/gnome-keyring.nix

    ../../nixos/audio.nix
    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix

    ../../nixos/fonts.nix

    ../../nixos/gaming.nix
    ../../nixos/1pass.nix
    ../../nixos/utils.nix
    ../../nixos/docker.nix
    ../../nixos/devenv.nix
    ../../nixos/home-manager.nix
    ../../nixos/ssh.nix
    ../../nixos/virtualisation.nix

    ../../homelab

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  environment.systemPackages = with pkgs; [
    unixtools.netstat
    cliphist # Clipboard history
    grim # Screenshotting
    slurp # Region select for screenshot
    wl-clipboard # Wayland clipboard utilities
    hyprpicker
    hyprshot

    bambu-studio
  ];



  networking = {
    defaultGateway = "192.168.20.1";
    nameservers = ["192.168.20.10"];
    interfaces.enp42s0 = {
      ipv4.addresses = [
        {
          address = "192.168.20.21";
          prefixLength = 24;
        }
      ];
    };
  };

  # Don't touch this
  system.stateVersion = "25.05";
}
