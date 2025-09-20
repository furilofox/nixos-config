{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  home.file.".config/direnv/direnvrc".text = ''
    source_env_if_exists() {
      if [ -f "$1" ]; then
        source_env "$1"
      fi
    }

    layout_devenv() {
      if [ -f devenv.nix ] || [ -f devenv.yaml ] || [ -f devenv.lock ]; then
        eval "$(devenv print-dev-env)"
      fi
    }
  '';
}
