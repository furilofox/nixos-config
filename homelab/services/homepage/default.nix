{pkgs, ...}: {
  services.homepage-dashboard = {
    enable = true;
    package = pkgs.homepage-dashboard;
    services = [
      {
        "Schule" = [
          {
            "node-red" = {
              description = "Node based Automation";
              href = "http://localhost:1880/";
            };
          }
        ];
      }
      {
        "Privat" = [
          {
            "Home Assistant" = {
              description = "Home Automation Dashboard";
              href = "http://localhost:8123/";
            };
          }
        ];
      }
    ];
  };

  services.glances = {
    enable = true;
  };
}
