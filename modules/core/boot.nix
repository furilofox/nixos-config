# Boot configuration module
{ config, lib, pkgs, ... }:
let
  cfg = config.boot;
in {
  # Note: Using config.boot.* conflicts with NixOS boot options
  # We extend the existing boot options instead

  config = {
    boot = {
      bootspec.enable = true;
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = lib.mkDefault true;
          consoleMode = "auto";
          configurationLimit = 8;
        };
      };
      tmp.cleanOnBoot = true;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
  };
}
