{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  directory = "/home/fabian/Pictures/wallpapers";
  wallpaper = directory + "/" + "dark-magical-forest.png";
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.packages = with pkgs; [
    inputs.quickshell.packages.${pkgs.system}.default
    inputs.noctalia.packages.${system}.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      settingsVersion = 12;
      bar = {
        position = "top";
        backgroundOpacity = 0;
        monitors = [];
        density = "compact";
        showCapsule = true;
        floating = false;
        marginVertical = 0.25;
        marginHorizontal = 0.25;
        widgets = {
          left = [
            {
              id = "SystemMonitor";
            }
            {
              id = "ActiveWindow";
            }
            {
              id = "MediaMini";
            }
          ];
          center = [
            {
              id = "Workspace";
            }
          ];
          right = [
            {
              id = "ScreenRecorder";
            }
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "WiFi";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "Battery";
            }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              id = "Clock";
            }
            {
              id = "ControlCenter";
            }
          ];
        };
      };
      general = {
        avatarImage = "";
        dimDesktop = true;
        showScreenCorners = true;
        forceBlackScreenCorners = false;
        radiusRatio = 0.5;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
      };
      location = {
        name = "Nuremberg";
        useFahrenheit = false;
        use12hourFormat = false;
        showWeekNumberInCalendar = false;
      };
      screenRecorder = {
        directory = "";
        frameRate = 60;
        audioCodec = "opus";
        videoCodec = "h264";
        quality = "very_high";
        colorRange = "limited";
        showCursor = true;
        audioSource = "default_output";
        videoSource = "portal";
      };
      wallpaper = {
        enabled = true;
        directory = directory;
        enableMultiMonitorDirectories = true;
        setWallpaperOnAllMonitors = true;
        fillMode = "crop";
        fillColor = "#000000";
        randomEnabled = false;
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
        monitors = [
          {
            name = "DP-2";
            directory = directory;
            wallpaper = wallpaper;
          }
          {
            name = "HDMI-A-2";
            directory = directory;
            wallpaper = wallpaper;
          }
          {
            name = "eDP-1";
            directory = directory;
            wallpaper = wallpaper;
          }
        ];
      };
      appLauncher = {
        enableClipboardHistory = true;
        position = "center";
        backgroundOpacity = 1;
        pinnedExecs = [];
        useApp2Unit = false;
        sortByMostUsed = true;
      };
      dock = {
        enabled = false;
        autoHide = true;
        exclusive = false;
        backgroundOpacity = 1;
        floatingRatio = 1;
        monitors = [];
        pinnedApps = [];
      };
      network = {
        wifiEnabled = true;
      };
      notifications = {
        doNotDisturb = false;
        monitors = [];
        location = "top_right";
        alwaysOnTop = false;
        lastSeenTs = 0;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
      };
      osd = {
        enabled = true;
        location = "top_right";
        monitors = [];
        autoHideMs = 2000;
      };
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 60;
        visualizerType = "linear";
        mprisBlacklist = [];
        preferredPlayer = "";
      };
      ui = {
        fontDefault = "Roboto";
        fontFixed = "DejaVu Sans Mono";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        monitorsScaling = [];
        idleInhibitorEnabled = false;
      };
      brightness = {
        brightnessStep = 5;
      };
      colorSchemes = {
        useWallpaperColors = true;
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        matugenSchemeType = "scheme-fruit-salad";
      };
      matugen = {
        gtk4 = true;
        gtk3 = true;
        qt6 = true;
        qt5 = true;
        kitty = true;
        ghostty = true;
        foot = true;
        fuzzel = true;
        vesktop = false;
        pywalfox = true;
        enableUserTemplates = false;
      };
      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };
      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
      };
    };
  };
}
