# Utility environment settings
{ config, lib, pkgs, ... }:
{
  options.utils = {
    defaultEditor = lib.mkOption {
      type = lib.types.str;
      default = "vscode";
      description = "Default text editor";
    };
    
    defaultBrowser = lib.mkOption {
      type = lib.types.str;
      default = "zen-beta";
      description = "Default web browser";
    };
  };

  config = {
    environment.variables = {
      EDITOR = config.utils.defaultEditor;
      BROWSER = config.utils.defaultBrowser;
    };
  };
}
