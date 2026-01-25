{
  description = ''
    Modular NixOS Configuration with Niri & Noctalia.
    Fully declarative with config.* options, profiles for shared configurations,
    and sops-nix secrets management.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # Note: quickshell follows removed - noctalia doesn't expose that input
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixcord.url = "github:kaylorben/nixcord";
    # stylix.url = "github:danth/stylix";

    caddy-nix = {
      url = "github:vincentbernat/caddy-nix";
      # Note: nixpkgs follows removed - caddy-nix doesn't expose that input
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private secrets repository (uncomment when ready)
    # my-secrets = {
    #   url = "git+ssh://git@github.com/YOUR_USERNAME/nixos-secrets.git";
    #   flake = false;
    # };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    # Import custom library with mkHost helper
    myLib = import ./lib { 
      inherit (nixpkgs) lib; 
      inherit inputs; 
    };
  in {
    nixosConfigurations = {
      # Desktop - uses desktop profile
      pandora = myLib.mkHost {
        hostname = "pandora";
        system = "x86_64-linux";
      };

      # Laptop - uses desktop profile  
      promethea = myLib.mkHost {
        hostname = "promethea";
        system = "x86_64-linux";
      };

      # Server - uses server profile
      athenas = myLib.mkHost {
        hostname = "athenas";
        system = "x86_64-linux";
      };
    };
  };
}

