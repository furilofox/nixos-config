# Promethea - Laptop Machine
# Uses desktop profile with laptop-specific overrides
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # Desktop profile - shared with pandora
    ../../profiles/desktop.nix
    
    # Hardware configuration
    ./hardware-configuration.nix
  ];

  # Host identification
  hostname = "promethea";
  username = "fabian";

  # Intel GPU (laptop)
  # TODO: Add Intel hardware module when migrating hardware/intel.nix

  # Laptop-specific monitor (built-in display)
  desktop.niri.monitors = [
    { name = "eDP-1"; width = 1920; height = 1080; refresh = 60; scale = 1.0; }
  ];

  # Laptop sensors (orientation, etc.)
  hardware.sensor.iio.enable = true;

  # Secrets configuration
  secrets = {
    enable = true;
    keyType = "age";
    sshKeyPaths = [ config.sshKeyPath ];
    # secretsRepo = inputs.my-secrets;  # Uncomment when private repo is ready
  };

  # Laptop power management
  services.power-profiles-daemon.enable = true;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    # Miracast support
    gnome-network-displays
  ];

  # Network configuration (using NetworkManager for laptop mobility)
  # Static networking will be overridden by NetworkManager when needed

  # Home-manager
  home-manager.users.${config.username} = import ./home.nix;

  system.stateVersion = "24.11";
}
