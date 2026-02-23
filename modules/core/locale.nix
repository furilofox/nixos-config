# Locale and timezone configuration
{
  config,
  lib,
  ...
}: let
  cfg = config.locale;
in {
  # Locale options are defined in modules/default.nix
  # This module applies those settings

  config = {
    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.defaultLocale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.extraLocale;
      LC_IDENTIFICATION = cfg.extraLocale;
      LC_MEASUREMENT = cfg.extraLocale;
      LC_MONETARY = cfg.extraLocale;
      LC_NAME = cfg.extraLocale;
      LC_NUMERIC = cfg.extraLocale;
      LC_PAPER = cfg.extraLocale;
      LC_TELEPHONE = cfg.extraLocale;
      LC_TIME = cfg.extraLocale;
    };

    console.keyMap = cfg.keyboardLayout;

    services.xserver = {
      xkb.layout = cfg.keyboardLayout;
      xkb.variant = "";
    };
  };
}
