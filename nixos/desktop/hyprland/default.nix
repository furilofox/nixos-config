{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./sddm.nix
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  # Force Wayland for other Apps and optimize for mixed refresh rates
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Chromium and Electron based Apps
    MOZ_ENABLE_WAYLAND = 1; # Firefox

    # Wayland/Hyprland optimizations for mixed refresh rates
    WLR_DRM_NO_ATOMIC = "1"; # Disable atomic modesetting (can help with flickering)
    __GL_SYNC_TO_VBLANK = "0"; # Disable VSync for better multi-monitor support
    __GL_VRR_ALLOWED = "1"; # Allow Variable Refresh Rate
    CLUTTER_DEFAULT_FPS = "144"; # Set max FPS for Clutter-based apps
  };

  environment.systemPackages = with pkgs; [
    waybar # Top Bar

    mako # Notification Daemon
    libnotify # Notifications

    swww # Wallpaper

    kitty # Terminal
  ];
}
