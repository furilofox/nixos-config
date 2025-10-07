{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./variables.nix

    # Programs
    ../../home/programs/zen
    ../../home/programs/discord
    ../../home/programs/git
    ../../home/programs/nextcloud
    ../../home/programs/1pass
    ../../home/programs/devenv

    # Scripts
    # ../../home/scripts # All scripts

    # System
    ../../home/system/hypr/hyprland
    ../../home/programs/quickshell
    ../../home/system/mime
    ../../home/system/udiskie
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
      kitty # Terminal

      # Apps

      # # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted
      xfce.thunar

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
