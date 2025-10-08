{config, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "athenas" = {
        host = "athenas";
        hostname = "192.168.20.10";
        user = config.var.username;
        forwardAgent = true;
      };

      "pandora" = {
        host = "pandora";
        hostname = "192.168.20.21";
        user = config.var.username;
        forwardAgent = true;
      };

      "promethea" = {
        host = "promethea";
        hostname = "192.168.20.22";
        user = config.var.username;
        forwardAgent = true;
      };

      "github-personal" = {
        host = "github.com";
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_personal";
        identitiesOnly = true;
      };

      "github-school" = {
        host = "github.com-school";
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_school";
        identitiesOnly = true;
      };

      "*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        identityFile = "~/.ssh/id_ed25519";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlPersist = "yes";
      };
    };
  };
}
