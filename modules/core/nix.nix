# Nix configuration and package management
{ config, lib, pkgs, inputs, ... }:
{
  # Allow rebuild without password for primary user
  security.sudo.extraRules = [
    {
      users = [ config.username ];
      commands = [
        { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nh"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/bin/nh"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nix"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/bin/nix"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nix-env"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/bin/nix-env"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/bin/systemctl"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/sw/bin/nix-env"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/activate"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/bin/switch-to-configuration"; options = [ "NOPASSWD" ]; }
        { command = "/nix/store/*/specialisation/*/bin/switch-to-configuration"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # Package configuration
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  # Better outputs for missing applications
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;

    extraOptions = ''
      warn-dirty = false
    '';

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      trusted-users = [ "root" config.username ];

      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://devenv.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:ZSz0K8xn/4WAhJrMhg4AqbhFDGILbehGfQbKXENXMdE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    alejandra
  ];

  programs.nh = {
    enable = true;
    flake = config.configDirectory;
    clean.enable = config.autoGarbageCollector;
    clean.extraArgs = "--keep-since 7d";
  };

  system.autoUpgrade = lib.mkIf config.autoUpgrade {
    enable = true;
    flake = "${config.configDirectory}";
    dates = "daily";
    flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
    allowReboot = false;
  };
}
