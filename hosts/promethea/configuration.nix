{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixos/hardware/intel.nix
    ../../nixos/hardware/touchpad.nix
    ../../nixos/hardware/fprint.nix
    ../../nixos/bluetooth.nix
    ../../nixos/miracast.nix

    ../../nixos/common
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/locale.nix
    ../../nixos/networking.nix

    ../../nixos/desktop/gnome

    ../../nixos/services/mullvad.nix
    ../../nixos/services/gnome-keyring.nix

    ../../nixos/audio.nix
    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix

    ../../nixos/fonts.nix

    ../../nixos/1pass.nix
    ../../nixos/utils.nix
    ../../nixos/docker.nix
    ../../nixos/devenv.nix
    ../../nixos/home-manager.nix
    ../../nixos/ssh.nix
    ../../nixos/virtualisation.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Orientation & other Sensors
  hardware.sensor.iio.enable = true;

  environment.systemPackages = with pkgs; [
    unixtools.netstat
    /* cliphist # Clipboard history
    grim # Screenshotting
    slurp # Region select for screenshot
    wl-clipboard # Wayland clipboard utilities
    hyprpicker
    hyprshot */

    dig # nslookup and stuff
  ];

  netbird.enableUi = true;

  networking = {
    defaultGateway = "192.168.20.1";
    nameservers = ["192.168.20.10" "1.1.1.1"];
    interfaces.wlp0s20f3 = {
      ipv4.addresses = [
        {
          address = "192.168.20.22";
          prefixLength = 24;
        }
      ];
    };
  };

  # Don't touch this
  system.stateVersion = "24.11";
}
