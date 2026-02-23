# Gaming module
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.gaming;
in {
  options.programs.gaming = {
    enable = lib.mkEnableOption "Gaming support (Steam, Gamescope, etc.)";

    steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = lib.mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    programs.gamemode.enable = true;

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
