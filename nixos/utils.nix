{
  pkgs,
  config,
  inputs,
  ...
}: {
  environment.variables = {
    EDITOR = "vscode";
    BROWSER = "zen-beta";
  };

  # Faster rebuilding
  /* documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  }; */
}
