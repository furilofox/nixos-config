# Brave is a privacy focused web browser.
{
  pkgs,
  inputs,
  ...
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # Ublock Origin Example
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };
}
