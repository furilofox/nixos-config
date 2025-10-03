{
  config,
  lib,
  ...
}: {
  imports = [
  ];

  config.var = {
    hostname = "pandora";
    username = "fabian";
    configDirectory =
      "/home/"
      + config.var.username
      + "/Documents/nixos-config";

    keyboardLayout = "de";

    location = "Berlin";
    timeZone = "Europe/Berlin";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "de_DE.UTF-8";

    git = {
      username = "furilo";
      email = "53122773+furilofox@users.noreply.github.com";
    };

    autoUpgrade = false;
    autoGarbageCollector = true;

    # Monitor configuration for Hyprland
    monitors = [
      "HDMI-A-2, 1920x1200@60, 0x0, 1"
      "DP-2, 2560x1440@144, 1920x-200, 1, vrr, 1"
    ];
  };

  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
