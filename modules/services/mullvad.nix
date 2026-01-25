# Mullvad VPN module
{ config, lib, pkgs, ... }:
let
  cfg = config.services.mullvad;
in {
  options.services.mullvad = {
    enable = lib.mkEnableOption "Mullvad VPN";
  };

  config = lib.mkIf cfg.enable {
    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    
    environment.systemPackages = [
      (pkgs.makeAutostartItem {
        name = "mullvad-vpn";
        package = pkgs.mullvad-vpn;
      })
    ];
  };
}
