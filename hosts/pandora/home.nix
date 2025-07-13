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
    ../../home/programs/kdeconnect

    # Scripts
    # ../../home/scripts # All scripts

    # System
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

      # Apps

      # # Gaming
      mangohud # Game Hardware stats
      protonup # "protonup" in terminal to download proton-ge
      lutris # great game launcher
      heroic # good for epicgames
      prismlauncher # Minecraft

      # # Dev
      devenv

      # # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted
      bottles # windows app container

      # # Just cool
      peaclock
      cbonsai
      pipes # pipes.sh -t [0-9]
      cmatrix

      # Unsorted
      obsidian # Note taking app
      easyeffects # Speaker / Mic Management
      nextcloud-client # File Sync
      telegram-desktop # Chatting
      bambu-studio # 3D-Printer
    ];

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
