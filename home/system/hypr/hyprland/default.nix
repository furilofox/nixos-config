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
    configType = "lua";
    
    # Use extraConfig for Lua-based configuration
    extraConfig = let
      # Convert monitor strings to Lua format
      monitorConfig = builtins.concatStringsSep "\n" (
        map (m: 
          let
            # Parse monitor string: "NAME, WIDTHxHEIGHT@RATE, X_OFFSETxY_OFFSET, SCALE[, vrr, VRR_VALUE]"
            parts = builtins.filter builtins.isString (builtins.split ", " m);
            name = builtins.elemAt parts 0;
            mode = builtins.elemAt parts 1;
            position = builtins.elemAt parts 2;
            scale = builtins.elemAt parts 3;
            hasVrr = builtins.length parts > 4;
          in
            if hasVrr then
              ''
                hl.monitor({
                  output   = "${name}",
                  mode     = "${mode}",
                  position = "${position}",
                  scale    = ${scale},
                  vrr      = ${builtins.elemAt parts 5},
                })
              ''
            else
              ''
                hl.monitor({
                  output   = "${name}",
                  mode     = "${mode}",
                  position = "${position}",
                  scale    = ${scale},
                })
              ''
        ) config.var.monitors
      );
    in ''
      -- Hyprland Lua Configuration
      
      --------------------
      ---- MONITORS ----
      --------------------
      
      ${monitorConfig}
      
      -- Fallback monitor
      hl.monitor({
        output   = "",
        mode     = "preferred",
        position = "auto",
        scale    = "auto",
      })
      
      
      ---------------------
      ---- MY PROGRAMS ----
      ---------------------
      
      local terminal = "kitty"
      local fileManager = "dolphin"
      local menu = "noctalia msg panel-toggle launcher"
      local lockScreen = "noctalia-shell ipc call lockScreen lock"
      local areaScreenshot = "hyprshot -m region --clipboard-only --freeze"
      
      
      -------------------
      ---- AUTOSTART ----
      -------------------
      
      hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia")
        hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY")
        hl.exec_cmd("gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
        hl.exec_cmd("wl-paste --watch cliphist store")
        hl.exec_cmd("discord")
        hl.exec_cmd("zen-beta")
        hl.exec_cmd("steam")
      end)
      
      
      -------------------------------
      ---- ENVIRONMENT VARIABLES ----
      -------------------------------
      
      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")
      
      
      -----------------------
      ---- CONFIGURATION ----
      -----------------------
      
      hl.config({
        input = {
          kb_layout = "de",
          follow_mouse = 1,
          sensitivity = 0,
          
          touchpad = {
            natural_scroll = true,
          },
        },
        
        general = {
          gaps_in = 2.5,
          gaps_out = 5,
          border_size = 1,
          
          col = {
            active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
          },
          
          resize_on_border = false,
          allow_tearing = false,
          layout = "dwindle",
        },
        
        decoration = {
          rounding = 5,
          active_opacity = 1.0,
          inactive_opacity = 0.95,
          
          shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
          },
          
          blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
          },
        },
        
        animations = {
          enabled = true,
          
          bezier = {
            { name = "easeOutQuint", points = {0.23, 1, 0.32, 1} },
            { name = "easeInOutCubic", points = {0.65, 0.05, 0.36, 1} },
            { name = "linear", points = {0, 0, 1, 1} },
            { name = "almostLinear", points = {0.5, 0.5, 0.75, 1.0} },
            { name = "quick", points = {0.15, 0, 0.1, 1} },
          },
          
          animation = {
            { name = "global", duration = 10, curve = "default", enabled = 1 },
            { name = "border", duration = 5.39, curve = "easeOutQuint", enabled = 1 },
            { name = "windows", duration = 4.79, curve = "easeOutQuint", enabled = 1 },
            { name = "windowsIn", duration = 4.1, curve = "easeOutQuint", style = "popin 87%", enabled = 1 },
            { name = "windowsOut", duration = 1.49, curve = "linear", style = "popin 87%", enabled = 1 },
            { name = "fadeIn", duration = 1.73, curve = "almostLinear", enabled = 1 },
            { name = "fadeOut", duration = 1.46, curve = "almostLinear", enabled = 1 },
            { name = "fade", duration = 3.03, curve = "quick", enabled = 1 },
            { name = "layers", duration = 3.81, curve = "easeOutQuint", enabled = 1 },
            { name = "layersIn", duration = 4, curve = "easeOutQuint", style = "fade", enabled = 1 },
            { name = "layersOut", duration = 1.5, curve = "linear", style = "fade", enabled = 1 },
            { name = "fadeLayersIn", duration = 1.79, curve = "almostLinear", enabled = 1 },
            { name = "fadeLayersOut", duration = 1.39, curve = "almostLinear", enabled = 1 },
            { name = "workspaces", duration = 1.94, curve = "almostLinear", style = "fade", enabled = 1 },
            { name = "workspacesIn", duration = 1.21, curve = "almostLinear", style = "fade", enabled = 1 },
            { name = "workspacesOut", duration = 1.94, curve = "almostLinear", style = "fade", enabled = 1 },
          },
        },
        
        master = {
          new_status = "master",
        },
        
        misc = {
          force_default_wallpaper = -1,
          disable_hyprland_logo = true,
          vrr = 1,
        },
      })
      
      
      --------------------
      ---- KEYBINDINGS ----
      --------------------
      
      local mainMod = "SUPER"
      
      -- Regular binds
      hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + C", hl.dsp.window.close())
      hl.bind(mainMod .. " + N", hl.dsp.exit())
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
      hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lockScreen))
      hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(areaScreenshot))
      hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m window"))
      
      -- Workspace bindings (1-9)
      for i = 1, 9 do
        hl.bind(mainMod .. " + code:1" .. (i-1), hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + code:1" .. (i-1), hl.dsp.window.move({ workspace = i }))
      end
      
      -- Mouse bindings
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
      
      -- Volume and brightness controls (locked and repeating)
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
      
      -- Media controls (locked)
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
      hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    '';
  };
}
