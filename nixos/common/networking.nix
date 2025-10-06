{config, ...}: let
  hostname = config.var.hostname;
in {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    networkmanager.dns = "none";
    nameservers = ["192.168.20.10" "1.1.1.1"];
    firewall = {
      enable = true;
    };
  };
}
