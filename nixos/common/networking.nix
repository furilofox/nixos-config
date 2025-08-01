{config, ...}: let
  hostname = config.var.hostname;
in {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
    };
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };
}
