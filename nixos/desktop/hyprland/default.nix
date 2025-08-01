{inputs,pkgs,...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # Force Wayland for other Apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Chromium and Electron based Apps
    MOZ_ENABLE_WAYLAND = 1; # Firefox
  };

  environment.systemPackages = with pkgs; [
    waybar # Top Bar

    mako # Notification Daemon
    libnotify # Notifications

    swww # Wallpaper

    inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins # App Launcher

    kitty # Terminal

    networkmanagerapplet # Network Manager UI
  ];
}
