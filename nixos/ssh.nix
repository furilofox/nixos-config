{
  config,
  pkgs,
  ...
}: {
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
      AllowUsers = [config.var.username];
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host athenas
        HostName 192.168.20.10
        User ${config.var.username}
        ForwardAgent yes

      Host pandora
        HostName 192.168.20.21
        User ${config.var.username}
        ForwardAgent yes

      Host promethea
        HostName 192.168.20.22
        User ${config.var.username}
        ForwardAgent yes

      Host *
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_ed25519
    '';
    knownHosts = {
      pandora = {
        hostNames = ["pandora" "192.168.20.21"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3akVuki5R7QbCLl5+l9l0IpxapzEOJ6acAwQBwxYcm fabian@pandora";
      };
      athenas = {
        hostNames = ["athenas" "192.168.20.10"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7fx0ZHLUDdCW9giuF9D5rqwHh7QC4PEGxcJd9Z1wZH fabian@athenas";
      };
      promethea = {
        hostNames = ["promethea" "192.168.20.22"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9feviQt7FkGvXKpWic+G+9q8wzTFzwIM/6EowDeTxi fabian@promethea";
      };
    };
  };

  users.users.${config.var.username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3akVuki5R7QbCLl5+l9l0IpxapzEOJ6acAwQBwxYcm fabian@pandora"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9feviQt7FkGvXKpWic+G+9q8wzTFzwIM/6EowDeTxi fabian@promethea"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7fx0ZHLUDdCW9giuF9D5rqwHh7QC4PEGxcJd9Z1wZH fabian@athenas"
    ];
  };
}
