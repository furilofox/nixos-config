{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      # Variables
      "$mainMod" = "SUPER";

      # Program variables
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "noctalia-shell ipc call launcher toggle";
      "$lockScreen" = "noctalia-shell ipc call lockScreen toggle";


      # Monitor configuration
      monitor = config.var.monitors ++ [",preferred,auto,auto"];


      # Autostart
      exec-once = [
        "noctalia-shell &"
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY &"
        "gnome-keyring-daemon --start --components=pkcs11,secrets,ssh &"
        "wl-paste --watch cliphist store &"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # General settings
      general = {
        gaps_in = 2.5;
        gaps_out = 5;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 5;
        rounding_power = 2;
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

      # Master layout
      master = {
        new_status = "master";
      };

      # Misc settings
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
        vrr = 1;
        vfr = true;
      };

      # Input configuration
      input = {
        kb_layout = "de";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = false;
        };
      };

      # Keybindings
      bind = [
        # Program launches
        "$mainMod,Q,exec,$terminal"
        "$mainMod,C,killactive,"
        "$mainMod,M,exit,"
        "$mainMod,E,exec,$fileManager"
        "$mainMod,V,togglefloating,"
        "$mainMod,P,pseudo,"
        "$mainMod,R,exec,$menu"
        "$mainMod,J,togglesplit,"
        "$mainMod,L,exec,$lockScreen"

        # Move focus with arrow keys
        "$mainMod,left,movefocus,l"
        "$mainMod,right,movefocus,r"
        "$mainMod,up,movefocus,u"
        "$mainMod,down,movefocus,d"

        # Workspace scroll
        "$mainMod,mouse_down,workspace,e+1"
        "$mainMod,mouse_up,workspace,e-1"

        # Screenshots
        ",PRINT,exec,hyprshot -m region"
        "$mainMod SHIFT,PRINT,exec,hyprshot -m window"
      ] ++ (
        # workspaces
        # binds $mainMod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mainMod, code:1${toString i}, workspace, ${toString ws}"
              "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

      # Mouse bindings
      bindm = [
        "$mainMod,mouse:272,movewindow"
        "$mainMod,mouse:273,resizewindow"
      ];

      # Volume and brightness controls
      bindel = [
        ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp,exec,brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown,exec,brightnessctl -e4 -n2 set 5%-"
      ];

      # Media controls
      bindl = [
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPause,exec,playerctl play-pause"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPrev,exec,playerctl previous"
      ];

      # Window rules
      windowrule = [
        "suppressevent maximize,class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };
  };
}
