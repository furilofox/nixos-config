{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable the X11 windowing system
  services = {
    xserver = {
      enable = true;

      # Configure keyboard
      xkb = {
        layout = config.var.keyboardLayout;
        variant = "";
      };
    };

    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };

    # Desktop environment
    desktopManager = {
      gnome.enable = true;
    };
  };

  services.displayManager.defaultSession = "gnome";

  # Force Wayland for other Apps
  environment.sessionVariables = {
    # Force Wayland for Chromium based applications
    NIXOS_OZONE_WL = "1";
    # Force Wayland for vscode
    ELECTRON_OZONE_PLATFORM_HINT = "x11";
    # Force Wayland for firefox
    MOZ_ENABLE_WAYLAND = 1;
  };

  environment.gnome.excludePackages = with pkgs; [
    cheese # photo booth
    eog # image viewer
    epiphany # web browser
    gedit # text editor
    simple-scan # document scanner
    totem # video player
    yelp # help viewer
    evince # document viewer
    file-roller # archive manager
    geary # email client
    seahorse # password manager

    # these should be self explanatory
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-photos
    gnome-screenshot
    gnome-system-monitor
    gnome-weather
    gnome-disk-utility
    pkgs.gnome-connections
    gnome-tour
  ];
}
