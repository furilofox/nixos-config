# Bluetooth module
{ config, lib, ... }:
let
  cfg = config.bluetooth;
in {
  options.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";
    
    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Power on Bluetooth adapter at boot";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
    };
    services.blueman.enable = true;
  };
}
