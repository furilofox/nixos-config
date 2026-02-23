# 1Password module
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.onepassword;
in {
  options.services.onepassword = {
    enable = lib.mkEnableOption "1Password password manager";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      _1password-cli
      _1password-gui
    ];

    programs = {
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [config.username];
      };
    };

    security.polkit.enable = true;

    systemd.user.services."1password-gui" = {
      enable = true;
      description = "1Password GUI";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
        Restart = "on-failure";
        TimeoutStopSec = 10;
      };
    };

    # Allow communication with Zen Browser
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          .zen-wrapped
          zen
        '';
        mode = "0755";
      };
    };
  };
}
