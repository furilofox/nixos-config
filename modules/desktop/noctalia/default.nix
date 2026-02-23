# Noctalia desktop shell module (packages managed by HM)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
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
}
