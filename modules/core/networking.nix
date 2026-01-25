# Networking configuration module
{ config, lib, ... }:
let
  cfg = config;
in {
  options.network = {
    enableNetworkManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use NetworkManager for network management";
    };
    
    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.20.10" "1.1.1.1" ];
      description = "DNS nameservers";
    };
  };

  config = {
    networking = {
      # hostName is set in modules/default.nix based on config.hostname
      networkmanager = lib.mkIf cfg.network.enableNetworkManager {
        enable = true;
        dns = "none";
      };
      nameservers = cfg.network.nameservers;
      firewall.enable = true;
    };
  };
}
