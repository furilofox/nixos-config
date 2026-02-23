# Browser options (packages managed by HM)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.programs.browsers;
in {
  options.programs.browsers = {
    zen.enable = lib.mkEnableOption "Zen Browser";
    brave.enable = lib.mkEnableOption "Brave Browser";
  };
}
