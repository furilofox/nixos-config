# Promethea - Laptop Home Manager configuration
{
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ../../home/desktop.nix
    ../../home/system/hardware/libinput.nix
  ];

  home = {
    username = osConfig.username;
    homeDirectory = "/home/${osConfig.username}";

    packages = with pkgs; [
      gnome-network-displays
      mongodb-compass
      onlyoffice-desktopeditors
      thunar
    ];

    stateVersion = "24.11";
  };
}
