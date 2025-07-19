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
    userName = username;
    userEmail = email;
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
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = "false";
      push.autoSetupRemote = true;
      color.ui = "1";

      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = {
        gpgsign = true;
      };

      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/OqDv8cbzLzx983fHgAupPVy15LKEmVmUR9bOc7GlU";
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
