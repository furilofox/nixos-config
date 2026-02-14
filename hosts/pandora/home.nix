# Pandora - Desktop Home Manager configuration
{
  pkgs,
  osConfig,
  inputs,
  ...
}: {
  imports = [
    # Programs
    ../../home/programs/zen
    ../../home/programs/discord
    ../../home/programs/git
    ../../home/programs/nextcloud
    ../../home/programs/devenv
    ../../home/programs/kitty
    ../../home/programs/ssh
    ../../home/programs/niri

    # Desktop shell
    ../../home/programs/quickshell

    # System
    ../../home/system/mime
    ../../home/system/udiskie
  ];

  home = {
    username = osConfig.username;
    homeDirectory = "/home/${osConfig.username}";

    packages = with pkgs; [
      # Wayland tools
      wl-clipboard
      cliphist
      grim
      slurp
      hyprpicker
      hyprshot

      # System Monitoring
      resources
      mission-center
      btop

      # Development
      vscode
      git
      bruno

      # Gaming
      mangohud
      protonup-ng
      lutris
      heroic
      (prismlauncher.override {
        additionalPrograms = [ffmpeg];
        jdks = [
          graalvmPackages.graalvm-ce
          zulu8
          zulu17
          zulu
        ];
      })

      # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted
      bottles
      nautilus
      unixtools.netstat
      dig

      # Fun
      peaclock
      cbonsai
      pipes
      cmatrix

      # Apps
      obsidian
      easyeffects
      nextcloud-client
      telegram-desktop
      pear-desktop
      antigravity

      # Pandora-specific
      satisfactorymodmanager
      shotcut
      yubikey-manager
      gnupg
    ];

    stateVersion = "25.05";
  };

  # Polkit authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = ["graphical-session.target"];
      After = ["graphical-session-pre.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      KillMode = "mixed";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  programs.home-manager.enable = true;
}
