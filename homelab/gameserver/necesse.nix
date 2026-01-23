{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.necesse-server;
  # Necesse requires Java 17+. We define it here to pass it explicitly.
  jdk = pkgs.jdk17;
  
  # Necesse App ID
  appId = "1169370";
in
{
  options.services.necesse-server = {
    enable = mkEnableOption "Necesse Dedicated Server";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/necesse";
      description = "Directory to store server data and save files.";
    };

    worldName = mkOption {
      type = types.str;
      default = "world";
      description = "Name of the world to load or create.";
    };

    port = mkOption {
      type = types.port;
      default = 14159;
      description = "Port for the server to listen on.";
    };

    slots = mkOption {
      type = types.int;
      default = 10;
      description = "Maximum number of players.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the default ports in the firewall.";
    };
  };

  config = mkIf cfg.enable {
    users.users.necesse = {
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
      group = "necesse";
      description = "Necesse Server service user";
    };
    users.groups.necesse = { };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.necesse-server = {
      description = "Necesse Dedicated Server";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      
      # --- FIX: This ensures the service starts on boot ---
      wantedBy = [ "multi-user.target" ]; 

      serviceConfig = {
        User = "necesse";
        Group = "necesse";
        WorkingDirectory = cfg.dataDir;
        Restart = "always";
        RestartSec = "10s";
        # Increase timeout for the first SteamCMD download
        TimeoutStartSec = "300"; 
      };

      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir ${cfg.dataDir} \
          +login anonymous \
          +app_update ${appId} validate \
          +quit
      '';

      # We explicitly use the jdk17 binary path to ensure the game finds Java
      script = ''
        ${pkgs.steam-run}/bin/steam-run ${jdk}/bin/java \
          -jar ${cfg.dataDir}/Server.jar \
          -nogui \
          -world "${cfg.worldName}" \
          -slots ${toString cfg.slots} \
          -port ${toString cfg.port}
      '';
    };
  };
}