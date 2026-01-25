# Nvidia GPU hardware module (stub)
{ config, lib, pkgs, ... }:
let
  cfg = config.hardware.nvidia;
in {
  options.hardware.nvidia = {
    enable = lib.mkEnableOption "Nvidia GPU support";
  };

  config = lib.mkIf cfg.enable {
    hardware.nvidia.modesetting.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
