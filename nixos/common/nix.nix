{
  config,
  inputs,
  pkgs,
  ...
}: let
  configDir = config.var.configDirectory;
  autoGC = config.var.autoGarbageCollector;
  autoUpgrade = config.var.autoUpgrade;
in {
  # Allow Rebuild without Password
  security.sudo.extraRules = [
    {
      users = [config.var.username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nh";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/bin/nh";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/bin/nix";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/bin/nix-env";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/bin/systemctl";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/sw/bin/nix-env";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/activate";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
        {
          command = "/nix/store/*/specialisation/*/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Allow other Packages
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
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

      # Add the user as trusted to allow devenv to manage caches
      trusted-users = ["root" config.var.username];

      # Add other package sources
      substituters = [
        # high priority since it's almost always used
        "https://cache.nixos.org?priority=10"

        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://devenv.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      ];
    };
  };

  # Add alejandra for nix formatting ("alejandra .")
  environment.systemPackages = with pkgs; [
    alejandra
  ];

  programs.nh = {
    enable = true;
    flake = configDir;

    # Auto Garbage collection
    clean.enable = autoGC;
    clean.extraArgs = "--keep-since 7d";
  };

  system.autoUpgrade = {
    enable = autoUpgrade;
    flake = "${configDir}";
    dates = "daily";
    flags = ["--update-input" "nixpkgs" "--commit-lock-file"];
    allowReboot = false;
  };
}
