# Desktop Profile - Shared configuration for pandora (desktop) and promethea (laptop)
{ config, lib, pkgs, ... }:
{
  # Enable desktop features
  audio = {
    enable = true;
    lowLatency = true;
    jack = true;
  };

  bluetooth.enable = true;

  # Desktop environment - Niri with noctalia
  desktop.niri = {
    enable = true;
    shell = "noctalia";
    layout.gaps = 8;
  };

  # Programs
  programs = {
    gaming.enable = true;
    development = {
      enable = true;
      docker.enable = true;
      devenv.enable = true;
    };
    browsers = {
      zen.enable = true;
      brave.enable = true;
    };
  };

  # Services
  services = {
    mullvad.enable = true;
    onepassword.enable = true;
    gnomeKeyring.enable = true;
  };

  # Secrets
  secrets.enable = true;

  # Common packages for desktop machines
  environment.systemPackages = with pkgs; [
    # Clipboard & screenshots
    wl-clipboard
    cliphist
    grim
    slurp
    hyprpicker
    hyprshot
    
    # Terminal
    kitty
    
    # Utilities
    unixtools.netstat
    dig
    
    # Sops utilities
    sops
    age
    ssh-to-age
  ];
}
