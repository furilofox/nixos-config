{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs
    ../../home/programs/anyrun
    ../../home/programs/brave
    ../../home/programs/discord
    ../../home/programs/git
    ../../home/programs/kitty
    ../../home/programs/nextcloud
    ../../home/programs/zen

    # Scripts
    ../../home/scripts # All scripts

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/hypridle
    ../../home/system/hyprlock
    ../../home/system/hyprpanel
    ../../home/system/hyprpaper
    ../../home/system/wofi
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      # Apps
      # bitwarden # Password manager
      # vlc # Video player
      # blanket # White-noise app
      # obsidian # Note taking app
      # # planify # Todolists
      # gnome-calendar # Calendar
      # textpieces # Manipulate texts
      # curtail # Compress images
      # resources
      # gnome-clocks
      # gnome-text-editor
      # mpv # Video player
      # figma-linux

      # # Dev
      # go
      # bun
      # nodejs
      # python3
      # jq
      # just
      # pnpm
      # air

      # # Utils
      # zip
      # unzip
      # optipng
      # jpegoptim
      # pfetch
      # btop
      # fastfetch

      # # Just cool
      # peaclock
      # cbonsai
      # pipes
      # cmatrix

      # # Backup
      # brave
      vscode
    ];

    # Don't touch this
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
