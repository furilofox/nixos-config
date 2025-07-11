{
  config,
  inputs,
  pkgs,
  ...
}: {
  # Allow Rebuild without Password
  security.sudo.extraRules = [
    {
      users = [config.var.username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Allow other Packages
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  # Better outputs for missing applications
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  nix = {
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    channel.enable = false;

    # Remove annoying dirty warning
    extraOptions = ''
      warn-dirty = false
    '';

    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];

      # Add other package sources
      substituters = [
        # high priority since it's almost always used
        "https://cache.nixos.org?priority=10"

        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
  };

  # Add alejandra for nix formatting ("alejandra .")
  environment.systemPackages = with pkgs; [
    alejandra
  ];

  programs.nh = {
    enable = true;
    # Auto Garbage collection
    clean.enable = config.var.autoGarbageCollector;
    clean.extraArgs = "--keep-since 14d --keep 5";
    flake = config.var.configDirectory;
  };
}
