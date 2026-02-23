# Niri scrollable-tiling Wayland compositor module
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.desktop.niri;
in {
  imports = [inputs.niri.nixosModules.niri];

  options.desktop.niri = {
    enable = lib.mkEnableOption "Niri scrollable-tiling Wayland compositor";

    shell = lib.mkOption {
      type = lib.types.enum ["noctalia" "waybar" "none"];
      default = "noctalia";
      description = "Desktop shell to use with Niri";
    };

    layout = {
      gaps = lib.mkOption {
        type = lib.types.int;
        default = 8;
        description = "Gap between windows in pixels";
      };

      border = {
        width = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "Window border width in pixels";
        };
      };
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration to append to niri config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    nixpkgs.overlays = [inputs.niri.overlays.niri];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
      qt6.qtwayland
      qt6.qtbase
      xwayland-satellite
      xwayland
    ];

    desktop.noctalia.enable = lib.mkIf (cfg.shell == "noctalia") true;

    # Disable niri-flake's built-in KDE polkit agent (we use polkit-gnome via Home Manager)
    systemd.user.services.niri-flake-polkit.enable = false;
  };
}
