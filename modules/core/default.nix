# Core system modules
{...}: {
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./home-manager.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./ssh.nix
    ./users.nix
    ./utils.nix
  ];
}
