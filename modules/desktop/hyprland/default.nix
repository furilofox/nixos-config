# Hyprland compositor module
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.desktop.hyprland;
in {
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland Wayland compositor";
    
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Monitor configuration strings in Hyprland format";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    # Force Wayland for other Apps and optimize for mixed refresh rates
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = 1;
      WLR_DRM_NO_ATOMIC = "1";
      __GL_SYNC_TO_VBLANK = "0";
      __GL_VRR_ALLOWED = "1";
      CLUTTER_DEFAULT_FPS = "144";
    };

    # Dependencies for shell
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    # Display manager (SDDM)
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
