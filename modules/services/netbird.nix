# Netbird - WireGuard-based mesh VPN
{ config, lib, pkgs, ... }:
let
  cfg = config.services.netbirdVpn;
in {
  options.services.netbirdVpn = {
    enable = lib.mkEnableOption "Netbird mesh VPN";

    ui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the Netbird desktop UI (for desktop systems)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the upstream NixOS netbird service (systemd + WireGuard)
    services.netbird.enable = true;

    environment.systemPackages =
      lib.optionals cfg.ui [ pkgs.netbird-ui ];
  };
}
