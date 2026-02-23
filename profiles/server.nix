# Server Profile - Configuration for athenas
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Minimal server configuration
  audio.enable = false;
  bluetooth.enable = false;

  # No desktop environment
  desktop.niri.enable = false;

  # Server secrets
  secrets.enable = true;

  # Mesh VPN (CLI only, no UI)
  services.netbirdVpn.enable = true;

  # SSH enabled by default
  ssh.enable = true;
}
