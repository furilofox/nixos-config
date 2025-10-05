{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.homelab.caddy;
  homelabCfg = config.homelab;
in {
  options.homelab.caddy = {
    enable = lib.mkEnableOption "Caddy reverse proxy with HTTPS certificates";

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 80;
      description = "HTTP port for Caddy";
    };

    httpsPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "HTTPS port for Caddy";
    };

    cloudflareApiToken = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Cloudflare API token for DNS challenge";
    };

    routes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          subdomain = lib.mkOption {
            type = lib.types.str;
            description = "Subdomain for the service (e.g., 'adguard' for adguard.local)";
          };
          upstream = lib.mkOption {
            type = lib.types.str;
            description = "Upstream URL to proxy to (e.g., 'http://localhost:3000')";
          };
          extraConfig = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Extra Caddy configuration for this route";
          };
        };
      });
      default = {};
      description = "Service routes configuration";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "local";
      description = "Base domain for services";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/caddy";
      description = "Data directory for Caddy";
    };
  };

  config = lib.mkIf (homelabCfg.enable && cfg.enable) {
    # Import caddy-nix overlay for plugin support
    nixpkgs.overlays = [
      inputs.caddy-nix.overlays.default
    ];

    services.caddy = {
      enable = true;
      dataDir = cfg.dataDir;

      # Use Caddy with Cloudflare plugin
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare"];
        hash = "sha256-j+xUy8OAjEo+bdMOkQ1kVqDnEkzKGTBIbMDVL7YDwDY=";
      };

      virtualHosts =
        lib.mapAttrs (name: route: {
          hostName = "${route.subdomain}.${cfg.domain}";
          extraConfig =
            ''
              reverse_proxy ${route.upstream}
              ${route.extraConfig}
            ''
            + lib.optionalString cfg.cloudflareApiToken
            != null ''
              tls {
                dns cloudflare {env.CLOUDFLARE_API_TOKEN}
              }
            '';
        })
        cfg.routes;
    };

    # Open firewall ports
    networking.firewall.allowedTCPPorts = [cfg.httpPort cfg.httpsPort];

    # Create systemd service to ensure proper startup
    systemd.services.caddy = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig = {
        # Ensure Caddy can bind to privileged ports
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
        NoNewPrivileges = true;
        User = "caddy";
        Group = "caddy";

        # Create data directory
        StateDirectory = "caddy";
        StateDirectoryMode = "0750";
      };
      environment = lib.mkIf (cfg.cloudflareApiToken != null) {
        CLOUDFLARE_API_TOKEN = cfg.cloudflareApiToken;
      };
    };

    # Create caddy user if not exists
    users.users.caddy = {
      isSystemUser = true;
      group = "caddy";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.caddy = {};

    # Add helpful aliases for service management
    environment.shellAliases = {
      caddy-reload = "sudo systemctl reload caddy";
      caddy-logs = "journalctl -u caddy -f";
    };
  };
}
