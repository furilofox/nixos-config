# Hyprland NixOS module
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.desktop.hyprland;
in {
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland Wayland compositor";

    shell = lib.mkOption {
      type = lib.types.enum ["noctalia" "waybar" "none"];
      default = "noctalia";
      description = "Desktop shell to use with Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    desktop.noctalia.enable = lib.mkIf (cfg.shell == "noctalia") true;

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
          user = "greeter";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
      qt6.qtwayland
      qt6.qtbase
    ];

    # Optimized environment variables for Hyprland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      WLR_DRM_NO_ATOMIC = "1";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}
