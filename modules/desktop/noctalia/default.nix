# Noctalia desktop shell module
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.desktop.noctalia;
in {
  options.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia desktop shell";
    
    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "lavender";
      description = "Color scheme for noctalia";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
