# Service modules
{...}: {
  imports = [
    ./mullvad.nix
    ./onepassword.nix
    ./gnome-keyring.nix
    ./kdeconnect.nix
    ./netbird.nix
  ];
}
