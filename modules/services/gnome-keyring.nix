# GNOME Keyring module
{ config, lib, pkgs, ... }:
let
  cfg = config.services.gnomeKeyring;
in {
  options.services.gnomeKeyring = {
    enable = lib.mkEnableOption "GNOME Keyring secret storage";
  };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;

    # Disable the GCR SSH agent since we're using the one from gnome-keyring
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

    security.pam.services = {
      sddm.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = true;
    };

    environment.systemPackages = with pkgs; [
      gnome-keyring
      libsecret
      seahorse
    ];
  };
}
