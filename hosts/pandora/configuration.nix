{
  config,
  pkgs,
  inputs,
  sops,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos
    ../../nixos/hardware/amd.nix

    ../../nixos/desktop/hyprland

    # Homelab services
    ../../homelab

    # ../../nixos/services/mullvad.nix
    ../../nixos/services/gnome-keyring.nix

    ../../nixos/printing.nix
    ../../nixos/ram-swap.nix

    ../../nixos/fonts.nix

    ../../nixos/gaming.nix
    ../../nixos/1pass.nix
    ../../nixos/docker.nix
    ../../nixos/devenv.nix
    ../../nixos/virtualisation.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  homelab = {
    enable = true;
    open-webui = {
      enable = true;
      port = 8080;
    };
  };

  environment.systemPackages = with pkgs; [
    unixtools.netstat
    cliphist # Clipboard history
    grim # Screenshotting
    slurp # Region select for screenshot
    wl-clipboard # Wayland clipboard utilities
    hyprpicker
    hyprshot

    # bambu-studio
    dig # nslookup and stuff
    kitty
    shotcut
    satisfactorymodmanager

    sops
    age
    ssh-to-age
    age-plugin-yubikey
    yubikey-manager
    gnupg # Yubikey / Sops stuff
  ];

  # YUBIKEY STUFF
  # ============================================

  services.pcscd.enable = true; # Required for Yubikey (Smart Card Daemon)

  environment.etc."sops/age/keys.txt".text = ''
    # Primary YubiKey (USB-C)
    AGE-PLUGIN-YUBIKEY-1C537CQVZFHGZCHS5QHCXQ

    # Backup YubiKey (USB-A)
    AGE-PLUGIN-YUBIKEY-1SRXDZQVZGULA6DQNFDM77
  '';
  environment.variables.SOPS_AGE_KEY_FILE = "/etc/sops/age/keys.txt";

  # Point to the secret file in the private input
  sops.defaultSopsFile = "${inputs.my-secrets}/secrets/general.yaml";
  sops.defaultSopsFormat = "yaml";

  # Machine uses its own SSH key to decrypt at boot (Runtime decryption)
  sops.age.sshKeyPaths = [config.ssh_key];

  # ============================================

  networking = {
    defaultGateway = "192.168.20.1";
    nameservers = ["192.168.20.10" "1.1.1.1"];
    interfaces.enp42s0 = {
      ipv4.addresses = [
        {
          address = "192.168.20.21";
          prefixLength = 24;
        }
      ];
    };
  };

  # Audio crackling fix

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  services.flatpak.enable = true;

  fileSystems."/mnt/nvme1n1" = {
    device = "/dev/disk/by-uuid/b71dcb90-1446-4118-bcdc-c862c74645c4";
    fsType = "ext4";
    options = [
      "users"
      "nofail"
      "exec"
    ];
  };

  systemd.services.chown-nvme1n1 = {
    description = "Change ownership of /mnt/nvme1n1 to the user";
    wantedBy = [ "multi-user.target" ];
    after = [ "mnt-nvme1n1.mount" ];
    requires = [ "mnt-nvme1n1.mount" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/chown ${config.var.username}:users /mnt/nvme1n1";
      RemainAfterExit = true;
    };
  };

  # Don't touch this
  system.stateVersion = "25.05";
}
