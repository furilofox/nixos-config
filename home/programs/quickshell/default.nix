{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  wallpaperDir = "/home/fabian/Pictures/wallpapers";
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = ./noctalia-config.toml;
  };
}
