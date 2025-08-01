{
  config,
  lib,
  ...
}: {
  virtualisation = {
    podman.enable = true;
    oci-containers = {
      containers = {
        homeassistant = {
          image = "homeassistant/home-assistant:stable";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
          ];
          volumes = [
            "home-assistant:/config"
          ];
          ports = [
            "127.0.0.1:8123:8123"
            "127.0.0.1:8124:80"
          ];
        };
      };
    };
  };
}
