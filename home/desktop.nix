# Shared desktop Home Manager configuration
{
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./programs/zen
    ./programs/discord
    ./programs/git
    ./programs/nextcloud
    ./programs/devenv
    ./programs/kitty
    ./programs/ssh
    ./programs/niri
    ./programs/brave
    ./programs/quickshell
    ./system/mime
    ./system/udiskie
  ];

  home = {
    packages = with pkgs; [
      wl-clipboard
      cliphist
      grim
      slurp
      hyprpicker
      hyprshot
      resources
      mission-center
      vscode
      git
      bruno
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted
      unixtools.netstat
      dig
      peaclock
      cbonsai
      pipes
      cmatrix
      bottles
      obsidian
      easyeffects
      nextcloud-client
      telegram-desktop
    ];

    sessionVariables = {
      EDITOR = osConfig.utils.defaultEditor;
      BROWSER = osConfig.utils.defaultBrowser;
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      vim_keys = true;
      rounded_corners = true;
      update_ms = 1000;
      proc_sorting = "cpu lazy";
      proc_tree = true;
      show_io_stat = true;
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah --color=auto";
      la = "ls -A --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      gl = "git log --oneline -20";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      nixr = "nh os switch .";
      nixb = "nh os build .";
      nixu = "nix flake update";
      nixg = "nh clean --keep 5 --keep-since 5d";
    };
    historyControl = [ "ignoredups" "erasedups" ];
    historySize = 50000;
    historyFileSize = 100000;
  };

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
