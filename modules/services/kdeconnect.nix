# KDE Connect - device integration (file transfer, notifications, clipboard sharing)
{ config, lib, pkgs, ... }:
let
  cfg = config.services.kdeConnect;
in {
  options.services.kdeConnect = {
    enable = lib.mkEnableOption "KDE Connect device integration";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;

    # Open firewall ports for KDE Connect (1714-1764 TCP+UDP)
    networking.firewall = {
      allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
      allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
    };
  };
}
