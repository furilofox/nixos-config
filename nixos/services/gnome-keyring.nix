{
  config,
  lib,
  pkgs,
  ...
}: {
  services.gnome.gnome-keyring.enable = true;

  # Disable the GCR SSH agent since we're using the one from gnome-keyring
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

  security.pam.services = {
    sddm.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
    seahorse # GUI for managing keyring
  ];
}
