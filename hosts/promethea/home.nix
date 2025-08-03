{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs
    # ../../home/programs/brave
    ../../home/programs/zen
    ../../home/programs/discord
    ../../home/programs/git
    # ../../home/programs/kitty
    ../../home/programs/nextcloud
    ../../home/programs/1pass
    # ../../home/programs/quickshell

    # Scripts
    # ../../home/scripts # All scripts

    # System
    ../../home/system/hardware/libinput.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      # System Monitoring
      resources # Shows System Ressources better
      mission-center # Shows Processes better
      btop # Console System Monitoring

      # Development
      vscode
      git
      bruno
      mongodb-compass

      bambu-studio

      # Apps

      # # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted

      # # Just cool
      peaclock
      cbonsai
      pipes # pipes.sh -t [0-9]
      cmatrix

      # Unsorted
      bottles # windows app container
      obsidian # Note taking app
      easyeffects # Speaker / Mic Management
      nextcloud-client # File Sync
      telegram-desktop # Chatting
    ];

    # Don't touch this
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
