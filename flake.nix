{
  description = ''
    Modular NixOS Configuration with Niri & Noctalia.
    Fully declarative with config.* options, profiles for shared configurations,
    and secrets management.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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
    };

    niri.url = "github:sodiboo/niri-flake";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixcord.url = "github:kaylorben/nixcord";

    caddy-nix = {
      url = "github:vincentbernat/caddy-nix";
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    # Import custom library with mkHost helper
    myLib = import ./lib {
      inherit (nixpkgs) lib;
      inherit inputs;
    };
  in {
    nixosConfigurations = {
      # Desktop
      pandora = myLib.mkHost {
        hostname = "pandora";
        system = "x86_64-linux";
      };

      # Laptop
      promethea = myLib.mkHost {
        hostname = "promethea";
        system = "x86_64-linux";
      };

      # Server
      athenas = myLib.mkHost {
        hostname = "athenas";
        system = "x86_64-linux";
      };
    };
  };
}
