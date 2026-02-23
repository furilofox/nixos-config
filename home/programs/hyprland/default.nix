# Hyprland Home Manager module
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  cfg = osConfig.desktop.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = let
        # Helper function to generate binds from a map
        generateBinds = keymap:
          pkgs.lib.flatten (
            pkgs.lib.mapAttrsToList (
              action: keys:
                map (key: "${key},${action}") keys
            )
            keymap
          );

        # Regular binds
        keybinds = {
          "exec,$terminal" = ["$mainMod,Q"];
          "killactive," = ["$mainMod,C"];
          "exit," = ["$mainMod,M"];
          "exec,$fileManager" = ["$mainMod,E"];
          "togglefloating," = ["$mainMod,V"];
          "pseudo," = ["$mainMod,P"];
          "exec,$menu" = ["$mainMod,R"];
          "togglesplit," = ["$mainMod,J"];
          "exec,$lockScreen" = ["$mainMod,L"];
          "movefocus,l" = ["$mainMod,left"];
          "movefocus,r" = ["$mainMod,right"];
          "movefocus,u" = ["$mainMod,up"];
          "movefocus,d" = ["$mainMod,down"];
          "workspace,e+1" = ["$mainMod,mouse_down"];
          "workspace,e-1" = ["$mainMod,mouse_up"];
        };

        # Mouse bindings
        mousebinds = {
          "movewindow" = ["$mainMod,mouse:272"];
          "resizewindow" = ["$mainMod,mouse:273"];
        };

        # Repeating binds (volume, brightness)
        repeatingBinds = {
          "exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" = [",XF86AudioRaiseVolume"];
          "exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" = [",XF86AudioLowerVolume"];
          "exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" = [",XF86AudioMute"];
          "exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" = [",XF86AudioMicMute"];
          "exec,brightnessctl -e4 -n2 set 5%+" = [",XF86MonBrightnessUp"];
          "exec,brightnessctl -e4 -n2 set 5%-" = [",XF86MonBrightnessDown"];
        };

        # Locked binds (media controls)
        lockedBinds = {
          "exec,playerctl next" = [",XF86AudioNext"];
          "exec,playerctl play-pause" = [",XF86AudioPause" ",XF86AudioPlay"];
          "exec,playerctl previous" = [",XF86AudioPrev"];
        };
      in {
        # Variables
        "$mainMod" = "SUPER";

        # Program variables
        "$terminal" = "kitty";
        "$fileManager" = "nautilus"; # Updated to nautilus as seen in Niri config
        "$menu" = "noctalia-shell ipc call launcher toggle";
        "$lockScreen" = "noctalia-shell ipc call lockScreen lock";

        bind =
          generateBinds keybinds
          ++ (
            # workspaces
            # binds $mainMod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mainMod, code:1${toString i}, workspace, ${toString ws}"
                  "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          )
          ++ [
            ",Print, exec, hyprshot -m region --clipboard-only --freeze"
            "CTRL, Print, exec, hyprshot -m output --clipboard-only"
            "ALT, Print, exec, hyprshot -m window --clipboard-only"
          ];
        bindm = generateBinds mousebinds;
        binde = generateBinds repeatingBinds;
        bindl = generateBinds lockedBinds;

        # Monitor configuration
        monitor =
          map (m: let
            offset = lib.replaceStrings [","] ["x"] m.position;
          in "${m.name},${toString m.width}x${toString m.height}@${toString m.refresh},${offset},${toString m.scale}")
          osConfig.desktop.monitors
          ++ [",preferred,auto,auto"];

        # Autostart
        exec-once = [
          "noctalia-shell &"
          "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY &"
          "gnome-keyring-daemon --start --components=pkcs11,secrets,ssh &"
          "wl-paste --watch cliphist store &"
          "easyeffects --daemon &"
        ];

        # Input configuration
        input = {
          kb_layout = "de";
          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
          };
        };

        # General settings
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        # Decoration
        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.95;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        # Animations
        animations = {
          enabled = true;
          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

          animation = [
            "global,1,10,default"
            "border,1,5.39,easeOutQuint"
            "windows,1,4.79,easeOutQuint"
            "windowsIn,1,4.1,easeOutQuint,popin 87%"
            "windowsOut,1,1.49,linear,popin 87%"
            "fadeIn,1,1.73,almostLinear"
            "fadeOut,1,1.46,almostLinear"
            "fade,1,3.03,quick"
            "layers,1,3.81,easeOutQuint"
            "layersIn,1,4,easeOutQuint,fade"
            "layersOut,1,1.5,linear,fade"
            "fadeLayersIn,1,1.79,almostLinear"
            "fadeLayersOut,1,1.39,almostLinear"
            "workspaces,1,1.94,almostLinear,fade"
            "workspacesIn,1,1.21,almostLinear,fade"
            "workspacesOut,1,1.94,almostLinear,fade"
          ];
        };

        # Dwindle layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Misc settings
        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = true;
          vrr = 1;
          vfr = true;
        };
      };
    };
  };
}
