{
  config,
  lib,
  ...
}: let
  service = "paperless";
  homelab = config.homelab;
  cfg = config.homelab.services.${service};
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    /*
       mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "${homelab.mounts.fast}/Documents/Paperless/Documents";
    };
    consumptionDir = lib.mkOption {
      type = lib.types.str;
      default = "${homelab.mounts.fast}/Documents/Paperless/Import";
    };
    */
    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "paperless.${homelab.baseDomain}";
    };
    useCaddy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to set up a Caddy reverse proxy for Paperless";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 28981;
      description = "Port for Paperless to listen on";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Paperless-ngx";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Document management system";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "si-paperlessngx";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      ${service} = {
        enable = true;
        passwordFile = lib.mkIf (cfg.passwordFile != null) cfg.passwordFile;
        user = homelab.user;
        port = cfg.port;
        /*
           mediaDir = cfg.mediaDir;
        consumptionDir = cfg.consumptionDir;
        */
        consumptionDirIsPublic = true;
        settings = {
          PAPERLESS_CONSUMER_IGNORE_PATTERN = [
            ".DS_STORE/*"
            "desktop.ini"
          ];
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_OCR_USER_ARGS = {
            optimize = 1;
            pdfa_image_compression = "lossless";
          };
        } // lib.optionalAttrs cfg.useCaddy {
          PAPERLESS_URL = "https://${cfg.url}";
        };
      };
    } // lib.optionalAttrs cfg.useCaddy {
      caddy.virtualHosts."${cfg.url}" = {
        # useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:${toString cfg.port}
        '';
      };
    };

    # Open the firewall port when not using Caddy (direct IP access)
    networking.firewall.allowedTCPPorts = lib.mkIf (!cfg.useCaddy) [cfg.port];
  };
}
