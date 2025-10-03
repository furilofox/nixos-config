{config, ...}: let
  hostname = config.var.hostname;
in {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    networkmanager.dns = "none";
    firewall = {
      enable = true;
    };
  };
}
