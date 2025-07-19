{
  pkgs,
  lib,
  ...
}: {
  services.node-red = {
    enable = true;
    withNpmAndGcc = true;
  };
  programs.nix-ld.enable = true;
  systemd.services.node-red = {
    path = with pkgs; [
      git
      bash
    ];
    environment = {
      NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
      NIX_LD_LIBRARY_PATH = with pkgs;
        lib.makeLibraryPath [
          zlib
          zstd
          stdenv.cc.cc
          curl
          openssl
          attr
          libssh
          bzip2
          libxml2
          acl
          libsodium
          util-linux
          xz
          systemd
        ];
    };
  };
}
