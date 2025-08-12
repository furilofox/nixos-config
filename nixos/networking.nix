{config, ...}: let
  hostname = config.var.hostname;
in {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
    };
  };
}
