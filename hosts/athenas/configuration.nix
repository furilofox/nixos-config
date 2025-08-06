{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/common
    ../../nixos/hardware/intel.nix
    ../../nixos/hardware/fprint.nix
    ../../nixos/ram-swap.nix
    ../../nixos/1pass.nix
    ../../nixos/utils.nix
    ../../nixos/ssh.nix

    ../../homelab/services/homepage

    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Prevent Suspend when lid closed
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  # Screen off after 30 Seconds
  boot.kernelParams = ["consoleblank=30"];

  homelab = {
    services = {
      homepage = {
        enable = true;

        # Example for Service without module in my Config
        /*
           misc = [
          {
            CustomApp = {
              description = "Some App not managed in this Config";
              url = "http://something.com";
              icon = "si-example";
            };
          }
        ];
        */
      };
    };
  };

  # Don't touch this
  system.stateVersion = "24.11";
}
