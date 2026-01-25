# Pandora - Desktop Machine
# Uses desktop profile with host-specific overrides
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # Desktop profile - shared with promethea
    ../../profiles/desktop.nix
    
    # Hardware configuration
    ./hardware-configuration.nix
  ];

  # Host identification
  hostname = "pandora";
  username = "fabian";

  # AMD GPU (desktop)
  hardware.amd = {
    enable = true;
    freesync = true;
  };

  # Monitor configuration for Niri
  desktop.niri.monitors = [
    { name = "HDMI-A-2"; width = 1920; height = 1200; refresh = 60; position = "0,0"; }
    { name = "DP-2"; width = 2560; height = 1440; refresh = 144; position = "1920,-200"; }
  ];

  # Secrets configuration with YubiKey
  secrets = {
    enable = true;
    keyType = "age-yubikey";
    sshKeyPaths = [ config.sshKeyPath ];
    # secretsRepo = inputs.my-secrets;  # Uncomment when private repo is ready
  };

  # YubiKey support
  services.pcscd.enable = true;
  
  # Age keys for YubiKey
  environment.etc."sops/age/keys.txt".text = ''
    # Primary YubiKey (USB-C)
    AGE-PLUGIN-YUBIKEY-1C537CQVZFHGZCHS5QHCXQ
    
    # Backup YubiKey (USB-A)
    AGE-PLUGIN-YUBIKEY-1SRXDZQVZGULA6DQNFDM77
  '';
  environment.variables.SOPS_AGE_KEY_FILE = "/etc/sops/age/keys.txt";

  # Pandora-specific packages
  environment.systemPackages = with pkgs; [
    satisfactorymodmanager
    shotcut
    age-plugin-yubikey
    yubikey-manager
    gnupg
  ];

  # Network configuration
  networking = {
    defaultGateway = "192.168.20.1";
    nameservers = [ "192.168.20.10" "1.1.1.1" ];
    interfaces.enp42s0 = {
      ipv4.addresses = [{
        address = "192.168.20.21";
        prefixLength = 24;
      }];
    };
  };

  # Audio crackling fix for pandora's specific hardware
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  # Home-manager
  home-manager.users.${config.username} = import ./home.nix;

  system.stateVersion = "25.05";
}
