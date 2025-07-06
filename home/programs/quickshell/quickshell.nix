{
  config,
  lib,
  pkgs,
  ...
}: let
  configDir = config.var.configDirectory;
  quickshellDir = "${configDir}/home/programs/quickshell/qml";
  quickshellTarget = "${homeDir}/.config/quickshell";
in {
  home.activation.symlinkQuickshellAndFaceIcon = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${quickshellDir}" "${quickshellTarget}"
  '';
}
