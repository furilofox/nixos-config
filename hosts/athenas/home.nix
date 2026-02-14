# Athenas - Server Home Manager configuration
{
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ../../home/programs/ssh
    ../../home/programs/git
  ];

  home = {
    username = osConfig.username;
    homeDirectory = "/home/${osConfig.username}";

    packages = with pkgs; [
      btop
      fastfetch
    ];

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
