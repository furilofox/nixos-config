# SDDM is a display manager for X11 and Wayland
{
  pkgs,
  inputs,
  config,
  ...
}: {
  services.displayManager = {
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      wayland.enable = true;

      extraPackages = [ pkgs.sddm-astronaut ];
      theme = "sddm-astronaut-theme";

      settings = {
        General = {
          # Remove forced wayland-only mode to allow fallback
          # DisplayServer = "wayland";
        };
        Wayland = {
          EnableHiDPI = true;
          # Ensure compositor is enabled for Wayland mode
          CompositorCommand = "${pkgs.kdePackages.kwin}/bin/kwin_wayland --no-lockscreen --inputmethod maliit-keyboard";
          # Use Adwaita cursor theme which is properly packaged
          CursorTheme = "Adwaita";
          CursorSize = 24;
        };
        Theme = {
          CursorTheme = "Adwaita";
          CursorSize = 24;
        };
      };
    };
    defaultSession = "hyprland-uwsm";
    gdm.enable = false;
    autoLogin.enable = false;
  };

  # Enable X11 support for SDDM fallback
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = false;
  };

  # Set environment variables for SDDM service
  systemd.services.display-manager.environment = {
    # Force software rendering for cursor to ensure visibility
    WLR_NO_HARDWARE_CURSORS = "1";
    # Set cursor theme and size explicitly
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    # Additional Qt cursor settings
    QT_CURSOR_THEME = "Adwaita";
    QT_CURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
    # Add Qt platform plugins for better compatibility
    qt6.qtwayland
    # Add cursor themes - ensure both icon theme and cursor package are installed
    adwaita-icon-theme
    gnome-themes-extra  # Contains Adwaita cursor theme
  ];
}
