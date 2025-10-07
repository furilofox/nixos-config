{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixos # General Nixos Stuff

    ../../nixos/hardware/intel.nix
    ../../nixos/hardware/touchpad.nix
    ../../nixos/hardware/fprint.nix
    ../../nixos/miracast.nix

    ../../nixos/desktop/hyprland

    ../../nixos/services/mullvad.nix
    ../../nixos/services/gnome-keyring.nix

    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix

    ../../nixos/fonts.nix

    ../../nixos/1pass.nix
    ../../nixos/docker.nix
    ../../nixos/devenv.nix
    ../../nixos/virtualisation.nix
    ../../nixos/gaming.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  system = {
    bluetooth.enable = true;
  };

  # Orientation & other Sensors
  hardware.sensor.iio.enable = true;

  environment.systemPackages = with pkgs; [
    unixtools.netstat
    /*
       cliphist # Clipboard history
    grim # Screenshotting
    slurp # Region select for screenshot
    wl-clipboard # Wayland clipboard utilities
    hyprpicker
    hyprshot
    */

    dig # nslookup and stuff
  ];

  netbird.enableUi = true;

  # Don't touch this
  system.stateVersion = "24.11";
}
