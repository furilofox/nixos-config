# Git configuration
{
  osConfig,
  ...
}: {
  programs.git = {
    enable = true;
    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      "*.elc"
      "auto-save-list"
      ".direnv/"
      "node_modules"
      "result"
      "result-*"
    ];
    settings = {
      user = {
        name = osConfig.git.username;
        email = osConfig.git.email;
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      color.ui = "auto";
    };
  };
}
