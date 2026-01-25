# Git configuration
{
  config,
  pkgs,
  lib,
  ...
}: let
  username = config.var.git.username;
  email = config.var.git.email;
in {
  programs.git = {
    enable = true;
    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      "*.elc"
      "auto-save-list"
      ".direnv/"
      "node_modules"
      "result"
      "result-*"
    ];
    settings = {
      user = {
        name = username;
        email = email;
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      color.ui = "auto";
    };
  };
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
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
  };
}
