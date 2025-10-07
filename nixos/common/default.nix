{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./home-manager.nix
    ./locale.nix
    ./netbird.nix
    ./networking.nix
    ./nix.nix
    ./ssh.nix
    ./users.nix
    ./utils.nix
  ];

  hardware.enableRedistributableFirmware = true;
}
