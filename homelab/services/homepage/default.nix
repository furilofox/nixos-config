{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.homepage;
in {
  options.homelab.services.homepage = {
    enable = lib.mkEnableOption {
      description = "Enable the Homepage Dashboard";
    };
  };

  config = lib.mkIf cfg.enable {
    services.glances.enable = true;
    services.homepage-dashboard = {
      enable = true;
      package = pkgs.homepage-dashboard;
      openFirewall = true;
      allowedHosts = "localhost:8082,127.0.0.1:8082,192.168.225.123:8082,homepage.home.local";

      settings = {
        layout = [
          {
            Glances = {
              header = false;
              style = "row";
              columns = 4;
            };
          }
        ];
        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };

      services = [
        {
          "Glances" = [
            {
              "Info" = {
                widget = {
                  type = "glances";
                  url = "http://localhost:61208";
                  metric = "info";
                  chart = true;
                  version = 4;
                };
              };
            }
            {
              "CPU Usage" = {
                widget = {
                  type = "glances";
                  url = "http://localhost:61208";
                  metric = "cpu";
                  chart = true;
                  version = 4;
                };
              };
            }
            {
              "Memory Usage" = {
                widget = {
                  type = "glances";
                  url = "http://localhost:61208";
                  metric = "memory";
                  chart = true;
                  version = 4;
                };
              };
            }
            {
              "Disk Usage" = {
                widget = {
                  type = "glances";
                  url = "http://localhost:61208";
                  metric = "disk:nvme0n1";
                  chart = true;
                  version = 4;
                };
              };
            }
          ];
        }
      ];
    };
  };
}
