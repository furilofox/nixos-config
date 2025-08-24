{
  config,
  pkgs,
  ...
}: {
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    # Don't let Home Manager manage the config file
    settings = {};
    extraConfig = "";
    sourceFirst = false;
    systemd.enable = false;
    xwayland.enable = true;
  };
  
  # Ensure the hyprland.conf is not managed by Home Manager
  xdg.configFile."hypr/hyprland.conf".enable = false;
}
