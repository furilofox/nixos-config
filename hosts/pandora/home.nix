# Pandora - Desktop Home Manager configuration
{
  pkgs,
  osConfig,
  inputs,
  ...
}: {
  imports = [
    ../../home/desktop.nix
  ];

  home = {
    username = osConfig.username;
    homeDirectory = "/home/${osConfig.username}";

    packages = with pkgs; [
      # Gaming
      mangohud
      protonup-ng
      lutris
      heroic
      (prismlauncher.override {
        additionalPrograms = [ffmpeg];
        jdks = [
          graalvmPackages.graalvm-ce
          zulu8
          zulu17
          zulu
        ];
      })

      nautilus
      mongodb-compass
      satisfactorymodmanager
      shotcut
      yubikey-manager
      gnupg
      pear-desktop
      antigravity
      onlyoffice-desktopeditors
    ];

    stateVersion = "25.05";
  };
}
