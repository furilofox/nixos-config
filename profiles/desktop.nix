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
    mullvad.enable = false;
    onepassword.enable = true;
    gnomeKeyring.enable = true;
    kdeConnect.enable = true;
    netbirdVpn = {
      enable = true;
      ui = true;
    };
  };

  # Secrets
  secrets.enable = true;

  # Enable udisks2 for udiskie (automount daemon)
  services.udisks2.enable = true;
}
