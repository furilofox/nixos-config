{config, ...}: let
  keyboardLayout = config.var.keyboardLayout;
  timeZone = config.var.timeZone;
  defaultLocale = config.var.defaultLocale;
  extraLocale = config.var.extraLocale;
in {
  time = {timeZone = timeZone;};
  i18n.defaultLocale = defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = extraLocale;
    LC_IDENTIFICATION = extraLocale;
    LC_MEASUREMENT = extraLocale;
    LC_MONETARY = extraLocale;
    LC_NAME = extraLocale;
    LC_NUMERIC = extraLocale;
    LC_PAPER = extraLocale;
    LC_TELEPHONE = extraLocale;
    LC_TIME = extraLocale;
  };
  console.keyMap = keyboardLayout;

  services = {
    xserver = {
      xkb.layout = keyboardLayout;
      xkb.variant = "";
    };
  };
}
