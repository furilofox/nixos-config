{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.netbird;
  enabled = cfg.enable;
  uiEnabled = cfg.enableUi;
in {
  options.netbird = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Netbird VPN CLI";
    };
    enableUi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Netbird VPN Desktop App";
    };
  };

  config = {
    services.netbird = {
      enable = enabled;
      ui.enable = uiEnabled;
    };
  };
}
