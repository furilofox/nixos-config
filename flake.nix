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
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixcord.url = "github:kaylorben/nixcord";
    # stylix.url = "github:danth/stylix";

    caddy-nix = {
      url = "github:vincentbernat/caddy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    hyprland,
    sops-nix,
    ...
  }: let
    mkHost = {modules}:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          sops = inputs.sops-nix;
        };

        modules = modules;
      };
  in {
    nixosConfigurations = {
      pandora = mkHost {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops

          ./hosts/pandora/configuration.nix
        ];
      };

      promethea = mkHost {
        modules = [
          inputs.home-manager.nixosModules.home-manager

          ./hosts/promethea/configuration.nix
        ];
      };

      athenas = mkHost {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nix-minecraft.nixosModules.minecraft-servers
          {nixpkgs.overlays = [inputs.nix-minecraft.overlay];}

          ./hosts/athenas/configuration.nix
        ];
      };
    };
  };
}
