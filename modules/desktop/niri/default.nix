# Niri scrollable-tiling Wayland compositor module
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.desktop.niri;
in {
  imports = [ inputs.niri.nixosModules.niri ];

  options.desktop.niri = {
    enable = lib.mkEnableOption "Niri scrollable-tiling Wayland compositor";
    
    shell = lib.mkOption {
      type = lib.types.enum [ "noctalia" "waybar" "none" ];
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

    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { 
            type = lib.types.str; 
            description = "Monitor output name (e.g., DP-1, HDMI-A-1)";
          };
          width = lib.mkOption { 
            type = lib.types.int; 
            description = "Resolution width";
          };
          height = lib.mkOption { 
            type = lib.types.int; 
            description = "Resolution height";
          };
          refresh = lib.mkOption { 
            type = lib.types.int; 
            default = 60; 
            description = "Refresh rate in Hz";
          };
          position = lib.mkOption { 
            type = lib.types.str; 
            default = "0,0"; 
            description = "Position as x,y";
          };
          scale = lib.mkOption { 
            type = lib.types.float; 
            default = 1.0; 
            description = "Display scale factor";
          };
        };
      });
      default = [];
      description = "Monitor configuration";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration to append to niri config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];


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
