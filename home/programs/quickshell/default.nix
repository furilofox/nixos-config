{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  configDir = config.var.configDirectory;
  homeDir = "/home/${config.var.username}";
  quickshellDir = "${configDir}/home/programs/quickshell/qml";
  quickshellTarget = "${homeDir}/.config/quickshell";
in {
  home.packages = with pkgs; [
    inputs.quickshell.packages.${pkgs.system}.default
  ];

  home.activation.symlinkQuickshell = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${quickshellDir}" "${quickshellTarget}"
  '';
}
