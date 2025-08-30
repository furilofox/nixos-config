{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    devenv
    direnv
    nix-direnv
    cachix
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = false;
  };

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };

  environment.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
}