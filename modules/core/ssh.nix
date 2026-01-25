# SSH configuration module
{ config, lib, pkgs, ... }:
{
  options.ssh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable OpenSSH server";
    };
    
    permitRootLogin = lib.mkOption {
      type = lib.types.str;
      default = "yes";
      description = "Whether to allow root login via SSH";
    };
  };

  config = lib.mkIf config.ssh.enable {
    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PermitRootLogin = config.ssh.permitRootLogin;
        AllowUsers = [ config.username ];
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
      knownHosts = {
        pandora = {
          extraHostNames = [ "pandora" "192.168.20.21" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3akVuki5R7QbCLl5+l9l0IpxapzEOJ6acAwQBwxYcm fabian@pandora";
        };
        athenas = {
          extraHostNames = [ "athenas" "192.168.20.10" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+VEZW7j6KqZzkzQmVWm7r8+hwcO50Z90PzRkkAs9UM fabian@athenas";
        };
        promethea = {
          extraHostNames = [ "promethea" "192.168.20.22" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfeLjwq/Yh3WSXg+5XMlurPguOFh5T7yo7UaiPiwbIc fabian@promethea";
        };
      };
    };

    users.users.${config.username} = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3akVuki5R7QbCLl5+l9l0IpxapzEOJ6acAwQBwxYcm fabian@pandora"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9feviQt7FkGvXKpWic+G+9q8wzTFzwIM/6EowDeTxi fabian@promethea"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7fx0ZHLUDdCW9giuF9D5rqwHh7QC4PEGxcJd9Z1wZH fabian@athenas"
      ];
    };
  };
}
