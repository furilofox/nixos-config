# SDDM is a display manager for X11 and Wayland
{
  pkgs,
  inputs,
  config,
  ...
}: {
  services.displayManager = {
    sddm = {
      package = pkgs.kdePackages.sddm;
      extraPackages = [sddm-astronaut];
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
      settings = {
        Wayland.SessionDir = "${
          inputs.hyprland.packages."${pkgs.system}".hyprland
        }/share/wayland-sessions";
      };
    };
  };

  environment.systemPackages = [sddm-astronaut];
}