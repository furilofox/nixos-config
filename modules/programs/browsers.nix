# Browser modules
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.programs.browsers;
in {
  options.programs.browsers = {
    zen.enable = lib.mkEnableOption "Zen Browser";
    brave.enable = lib.mkEnableOption "Brave Browser";
  };

  config = {
    environment.systemPackages = lib.flatten [
      (lib.optional cfg.zen.enable inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
      (lib.optional cfg.brave.enable pkgs.brave)
    ];
  };
}
