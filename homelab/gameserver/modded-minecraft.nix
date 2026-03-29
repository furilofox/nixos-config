# Stop the server
# sudo systemctl stop modded-minecraft-server

# Start the server
# sudo systemctl start modded-minecraft-server

# Restart the server
# sudo systemctl restart modded-minecraft-server

# Check status
# sudo systemctl status modded-minecraft-server

# View live logs
# sudo journalctl -u modded-minecraft-server -f


{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.modded-minecraft-server;
in {
  options.services.modded-minecraft-server = {
    enable = mkEnableOption "Modded Minecraft (Forge) server";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/modded-minecraft";
      description = "Directory to store server data, world saves, and mods.";
    };

    serverPackZip = mkOption {
      type = types.path;
      description = ''
        Path to the modpack server pack ZIP file.
        Download from CurseForge and place in this repository.
      '';
    };

    javaPackage = mkOption {
      type = types.package;
      default = pkgs.jdk17;
      description = "Java package to use. Forge 1.20.1 requires Java 17.";
    };

    memory = mkOption {
      type = types.str;
      default = "6G";
      description = "Maximum heap memory allocation for the server (e.g. '6G', '8G').";
    };

    port = mkOption {
      type = types.port;
      default = 25565;
      description = "Port for the Minecraft server to listen on.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the server port in the firewall.";
    };

    eula = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to accept the Minecraft EULA.
        Must be set to true for the server to start.
        See: https://aka.ms/MinecraftEULA
      '';
    };

    serverProperties = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        motd = "My Modded Server";
        max-players = "10";
        difficulty = "hard";
      };
      description = ''
        Additional server.properties key-value pairs to set.
        These are applied on every start, overriding values in the file.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.eula;
        message = "You must accept the Minecraft EULA by setting services.modded-minecraft-server.eula = true";
      }
    ];

    users.users.minecraft = {
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
      group = "minecraft";
      description = "Modded Minecraft server user";
    };
    users.groups.minecraft = {};

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };

    systemd.services.modded-minecraft-server = {
      description = "Modded Minecraft (Forge) Server";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "minecraft";
        Group = "minecraft";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        RestartSec = "15s";
        # First run downloads Forge libraries — give it time
        TimeoutStartSec = "600";
        # Graceful shutdown via RCON stop or SIGTERM
        KillSignal = "SIGTERM";
        TimeoutStopSec = "120";
        SuccessExitStatus = "0 130";
      };

      preStart = ''
        # --- Extract server pack on first install ---
        if [ ! -f "${cfg.dataDir}/.installed" ]; then
          echo "First run: extracting server pack..."
          ${pkgs.unzip}/bin/unzip -o "${cfg.serverPackZip}" -d "${cfg.dataDir}"
          echo "Server pack extracted."
        fi

        # --- Run Forge installer if libraries are missing ---
        if [ ! -d "${cfg.dataDir}/libraries" ]; then
          echo "Running Forge installer..."
          INSTALLER=$(find "${cfg.dataDir}" -maxdepth 1 -name "forge-*-installer.jar" | head -1)
          if [ -n "$INSTALLER" ]; then
            ${cfg.javaPackage}/bin/java -jar "$INSTALLER" --installServer "${cfg.dataDir}"
            echo "Forge installed successfully."
          else
            echo "ERROR: No forge installer jar found!"
            exit 1
          fi
        fi

        # --- Mark as installed after both extraction and Forge install ---
        touch "${cfg.dataDir}/.installed"

        # --- Accept EULA ---
        echo "eula=true" > "${cfg.dataDir}/eula.txt"

        # --- Apply server.properties overrides ---
        PROPS="${cfg.dataDir}/server.properties"
        if [ ! -f "$PROPS" ]; then
          touch "$PROPS"
        fi
        ${concatStringsSep "\n" (mapAttrsToList (key: value: ''
            if ${pkgs.gnugrep}/bin/grep -q "^${key}=" "$PROPS"; then
              ${pkgs.gnused}/bin/sed -i "s|^${key}=.*|${key}=${value}|" "$PROPS"
            else
              echo "${key}=${value}" >> "$PROPS"
            fi
          '')
          (cfg.serverProperties
            // {
              server-port = toString cfg.port;
            }))}

        # --- Make startup scripts executable ---
        for f in "${cfg.dataDir}"/*.sh; do
          [ -f "$f" ] && chmod +x "$f"
        done
      '';

      script = ''
        cd "${cfg.dataDir}"

        # Find the unix_args.txt generated by the Forge installer
        UNIX_ARGS=$(find "${cfg.dataDir}/libraries/net/minecraftforge/forge" -name "unix_args.txt" 2>/dev/null | head -1)

        if [ -n "$UNIX_ARGS" ]; then
          echo "Starting Forge server using $UNIX_ARGS"
          exec ${cfg.javaPackage}/bin/java \
            -Xmx${cfg.memory} -Xms${cfg.memory} \
            @"$UNIX_ARGS" \
            nogui "$@"
        else
          # Fallback: find forge server jar directly
          FORGE_JAR=$(find . -maxdepth 1 -name "forge-*.jar" -not -name "*installer*" | head -1)
          if [ -z "$FORGE_JAR" ]; then
            echo "ERROR: Could not find Forge server JAR or unix_args.txt. Check your server pack."
            exit 1
          fi
          exec ${cfg.javaPackage}/bin/java \
            -Xmx${cfg.memory} -Xms${cfg.memory} \
            -jar "$FORGE_JAR" nogui
        fi
      '';
    };
  };
}