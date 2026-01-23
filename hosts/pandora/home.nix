{
  pkgs,
  config,
  inputs,
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
    ../../home/programs/devenv

    # Scripts
    # ../../home/scripts # All scripts

    # System
    ../../home/system/hypr/hyprland
    ../../home/system/mime
    ../../home/system/udiskie
    ../../home/programs/quickshell
    ../../home/programs/ssh
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

      # Apps

      # # Gaming
      mangohud # Game Hardware stats
      protonup-ng # "protonup" in terminal to download proton-ge
      lutris # great game launcher
      heroic # good for epicgames
      (prismlauncher.override {
        # Minecraft
        additionalPrograms = [ffmpeg];
        jdks = [
          graalvmPackages.graalvm-ce
          zulu8
          zulu17
          zulu
        ];
      })

      # # Utils
      zip
      unzip
      optipng
      jpegoptim
      pfetch
      fastfetch
      gparted
      bottles # windows app container
      nautilus # File Manager (Gnome Files)

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
      youtube-music
      antigravity
    ];

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
