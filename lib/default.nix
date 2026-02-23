# Custom library functions for NixOS configuration
{
  lib,
  inputs,
  ...
}: let
  # Helper to create a host configuration
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    extraModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs hostname;
        myLib = import ./. {inherit lib inputs;};
      };
      modules =
        [
          # Core modules from flake inputs
          inputs.home-manager.nixosModules.home-manager

          # Our module system
          ../modules

          # Host-specific configuration
          ../hosts/${hostname}
        ]
        ++ extraModules;
    };
in {
  inherit mkHost;
}
