{
  # https://github.com/anotherhadi/nixy
  description = ''
    Nixy simplifies and unifies the Hyprland ecosystem with a modular, easily customizable setup.
    It provides a structured way to manage your system configuration and dotfiles with minimal effort.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";

    # stylix.url = "github:danth/stylix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixcord.url = "github:kaylorben/nixcord";
    # sops-nix.url = "github:Mic92/sops-nix";
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-python,
    ...
  }: let
    mkHost = {modules}:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };

        modules = modules;
      };
  in {
    nixosConfigurations = {
      pandora = mkHost {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          # inputs.stylix.nixosModules.stylix

          ./hosts/pandora/configuration.nix
        ];
      };

      promethea = mkHost {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          # inputs.stylix.nixosModules.stylix

          ./hosts/promethea/configuration.nix
        ];
      };

      athenas = mkHost {
        modules = [
          ./hosts/athenas/configuration.nix
        ];
      };
    };
  };
}
