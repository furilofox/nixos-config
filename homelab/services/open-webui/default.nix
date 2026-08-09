{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.homelab.open-webui;
in {
  options.homelab.open-webui = {
    enable = lib.mkEnableOption {
      description = "Enable Open WebUI";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to run Open WebUI on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      port = cfg.port;
      environment = {
        WEBUI_AUTH = "False";
        ANONYMIZED_TELEMETRY = "False";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
