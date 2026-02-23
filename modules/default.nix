# Unified module system - imports all modules and defines global options
{
  config,
  lib,
  pkgs,
  inputs,
  hostname,
  ...
}: {
  imports = [
    ./core
    ./desktop
    ./programs
    ./services
    ./hardware
    ./secrets
  ];

  # Global configuration options
  options = {
    # Hostname - set by mkHost
    hostname = lib.mkOption {
      type = lib.types.str;
      default = hostname;
      description = "System hostname";
    };

    # Primary user configuration
    username = lib.mkOption {
      type = lib.types.str;
      default = "fabian";
      description = "Primary user account name";
    };

    # Configuration directory path
    configDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.username}/Documents/nixos-config";
      description = "Path to the NixOS configuration repository";
    };

    # Locale settings
    locale = {
      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "de";
        description = "Keyboard layout";
      };

      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Berlin";
        description = "System timezone";
      };

      defaultLocale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "Default system locale";
      };

      extraLocale = lib.mkOption {
        type = lib.types.str;
        default = "de_DE.UTF-8";
        description = "Extra locale for regional formats";
      };
    };

    # Git configuration
    git = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "furilo";
        description = "Git username";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "53122773+furilofox@users.noreply.github.com";
        description = "Git email address";
      };
    };

    # SSH key path
    sshKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.username}/.ssh/id_ed25519";
      description = "Path to primary SSH private key";
    };

    # System maintenance options
    autoUpgrade = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic system upgrades";
    };

    autoGarbageCollector = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable automatic garbage collection";
    };
  };

  # Apply hostname to networking
  config = {
    networking.hostName = config.hostname;
  };
}
