{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs
    ../../home/programs/git
    ../../home/programs/nextcloud
    ../../home/programs/1pass

    # System
    ../../home/system/hardware/libinput.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      git
      nextcloud-client # File Sync
    ];

    # Don't touch this
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
