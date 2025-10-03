{
  config,
  lib,
  ...
}: {
  imports = [
  ];

  config.var = {
    hostname = "promethea";
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

    # Monitor configuration for Hyprland (automatic)
    monitors = [];
  };

  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
