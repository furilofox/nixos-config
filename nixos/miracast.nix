# Screenshare over Network via. Miracast (using Gnome Display Manager).
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];

  # Allow Ports
  networking.firewall.allowedTCPPorts = [7236 7250];
  networking.firewall.allowedUDPPorts = [7236 5353];
}
