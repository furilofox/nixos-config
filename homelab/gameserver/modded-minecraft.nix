# Modded Minecraft server using nix-minecraft
# https://github.com/Infinidoge/nix-minecraft
#
# Manage the server:
#   sudo systemctl stop minecraft-server-modded
#   sudo systemctl start minecraft-server-modded
#   sudo systemctl restart minecraft-server-modded
#   sudo systemctl status minecraft-server-modded
#
# Attach to the server console:
#   sudo tmux -S /run/minecraft/modded.sock attach
#   (press Ctrl+b then d to detach)
#
# View logs:
#   sudo journalctl -u minecraft-server-modded -f
#
# Server data is stored in: /srv/minecraft/modded
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.modded-minecraft;

  # Extract the CurseForge server pack into the nix store
  serverPack = pkgs.stdenv.mkDerivation {
    name = "minecraft-serverpack";
    src = cfg.serverPackZip;
    nativeBuildInputs = [pkgs.unzip];
    sourceRoot = ".";
    unpackCmd = "unzip $curSrc -d .";
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };
in {
  options.services.modded-minecraft = {
    enable = lib.mkEnableOption "Modded Minecraft server (via nix-minecraft)";

    serverPackZip = lib.mkOption {
      type = lib.types.path;
      description = "Path to the CurseForge modpack server pack ZIP file.";
    };

    serverProperties = lib.mkOption {
      type = lib.types.attrsOf (lib.types.oneOf [lib.types.bool lib.types.int lib.types.str]);
      default = {};
      example = {
        motd = "My Modded Server";
        max-players = 10;
      };
      description = "Minecraft server.properties — see https://minecraft.wiki/w/Server.properties";
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers.modded = {
        enable = true;
        openFirewall = true;

        # NeoForge 1.21.1 — nix-minecraft handles the server jar natively
        package = pkgs.neoforgeServers.neoforge-1_21_1;

        jvmOpts = "-Xmx6G -Xms6G";

        serverProperties = cfg.serverProperties;

        # Symlink modpack mods and config from the nix store.
        # Symlinks are read-only, which is fine for mods and most config.
        symlinks = {
          "mods" = "${serverPack}/mods";
        };

        # Copy config as writable files (some mods write to their config)
        files = {
          "config" = "${serverPack}/config";
        };
      };
    };
  };
}
