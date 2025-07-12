# Zen is a minimalistic web browser.
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs.firefoxpwa];
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      AutofillAddressesEnabled = false;
      AutoFillCreditCardEnabled = false;
      DisablePocket = true;
      DisableProfileImport = true;
      DisableSetDesktopBackground = true;
      DontCheckDefaultBrowser = true;
      StartPage = "homepage";
      NewTabPage = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionSettings = {
        # 1Password
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      # find more options here: https://mozilla.github.io/policy-templates/
    };
  };
}
