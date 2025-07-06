{
  config,
  pkgs,
  ...
}: {
  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;

    # Basic Hyprland configuration
    settings = {
      # Monitor configuration
      monitor = [
        ",preferred,auto,auto"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
      };

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      # Decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = false;
      };

      # Misc
      misc = {
        force_default_wallpaper = -1;
      };

      # Key bindings
      "$mod" = "SUPER";

      bind = [
        # Basic bindings
        "$mod, Q, exec, kitty"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, dolphin"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Launch anyrun
        "$mod, R, exec, anyrun"

        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scroll through existing workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Window rules
      windowrule = [
        "float, ^(anyrun)$"
        "pin, ^(anyrun)$"
        "stayfocused, ^(anyrun)$"
      ];

      # Autostart applications
      exec-once = [
        "~/.config/hypr/autostart.sh"
      ];
    };
  };

  # Create autostart script
  home.file.".config/hypr/autostart.sh" = {
    text = ''
      #!/bin/bash

      # Wait a moment for the desktop to load
      # sleep 2

      # Start anyrun daemon (if it has daemon mode)
      # Comment out if anyrun doesn't have a daemon mode
      anyrun --daemon &

      # Optional: Start other applications
      waybar &
      # hyprpaper &
      # mako &

      # Optional: Set wallpaper
      # hyprctl hyprpaper wallpaper "eDP-1,/path/to/wallpaper.jpg"

      echo "Hyprland autostart completed"
    '';
    executable = true;
  };
}
