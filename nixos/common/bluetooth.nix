{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.system.bluetooth;
  enabled = cfg.enable;
in {
  options.system.bluetooth = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Bluetooth on System";
    };
  };

  config = lib.mkIf enabled {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
