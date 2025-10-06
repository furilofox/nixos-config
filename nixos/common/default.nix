{
  imports = [
    ./netbird.nix
    ./ssh.nix
    ./locale.nix
    ./home-manager.nix
    ./ssh.nix
    ./users.nix
    ./nix.nix
    ./boot.nix
    ./networking.nix
  ];

  hardware.enableRedistributableFirmware = true;
}
