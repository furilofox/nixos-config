{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.minecraft-server;
  mcServerDir = "/home/${config.var.username}/Documents/mcserver";

  # Package the server zip file so it's available in the nix store
  serverPackage = pkgs.runCommand "minecraft-server-files" {} ''
    mkdir -p $out
    cp ${./server-1.3.1.zip} $out/server-1.3.1.zip
  '';
in {
  options.homelab.services.minecraft-server = {
    enable = lib.mkEnableOption "Minecraft server with custom setup";
  };

  config = lib.mkIf cfg.enable {
    # Install Java 21 for Minecraft server
    environment.systemPackages = [pkgs.openjdk21];

    # Open Minecraft default port
    networking.firewall.allowedTCPPorts = [25565];
    networking.firewall.allowedUDPPorts = [25565];

    # Create a oneshot systemd service to set up the server files
    systemd.services.minecraft-server-setup = {
      description = "Setup Minecraft server files";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
        # Create mcserver directory if it doesn't exist
        mkdir -p ${mcServerDir}

        # Check if server files need to be extracted
        if [ ! -f ${mcServerDir}/.extracted ]; then
          echo "Extracting Minecraft server files..."
          ${pkgs.unzip}/bin/unzip -o ${serverPackage}/server-1.3.1.zip -d ${mcServerDir}
          touch ${mcServerDir}/.extracted
          echo "Server files extracted successfully"
        else
          echo "Server files already extracted"
        fi

        # Create symlink for convenience
        if [ ! -L ${mcServerDir}/server-1.3.1.zip ]; then
          ln -sf ${serverPackage}/server-1.3.1.zip ${mcServerDir}/server-1.3.1.zip
        fi

        # Set proper ownership
        chown -R ${config.var.username}:users ${mcServerDir}
      '';
    };
  };
}
