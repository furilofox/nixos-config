# Promethea - Laptop Home Manager configuration
{
  pkgs,
  osConfig,
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
    ../../home/system/hardware/libinput.nix
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
      mongodb-compass

      # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted
      thunar
      unixtools.netstat
      dig

      # Fun
      peaclock
      cbonsai
      pipes
      cmatrix

      # Apps
      bottles
      obsidian
      easyeffects
      nextcloud-client
      telegram-desktop
      onlyoffice-desktopeditors

      # Miracast
      gnome-network-displays
    ];

    stateVersion = "24.11";
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
