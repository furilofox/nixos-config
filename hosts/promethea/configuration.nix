{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    # ../../nixos/common
    # ../../nixos/hardware/intel.nix

    # ../../nixos/audio.nix
    # ../../nixos/bluetooth.nix
    # ../../nixos/fonts.nix
    ../../nixos/gnome.nix
    # ../../nixos/utils.nix

    # ../../nixos/touchpad.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;

  # Enable PipeWire as the audio server
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable printer support
  services.printing = {
    enable = true;
    drivers = [pkgs.gutenprint pkgs.hplip];
  };
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # Formatting
  environment.systemPackages = with pkgs; [
    alejandra
  ];

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  nixpkgs.config.nix.settings = {
    experimental-features = lib.mkAfter ["flakes" "nix-command"];
    formatter = "${pkgs.alejandra}/bin/alejandra";
  };

  # Locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  console.keyMap = "de";

  # Nix
  nix = {
    # Enable flakes and new 'nix' command
    package = pkgs.nixVersions.latest;

    # Optimize store
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      trusted-users = ["root" "@wheel"];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["intel_pstate=active"];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        mesa
      ];
    };
  };

  # Virtual RAM / RAM Compression and stuff
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
  zramSwap.enable = true;

  networking.hostName = "promethea"; # Define your hostname.

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabian = {
    isNormalUser = true;
    description = "Fabian";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Fingerprint Support
  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  security.pam.services.gdm-password.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.fprintAuth = false;
  security.pam.services.gdm-fingerprint = lib.mkIf (config.services.fprintd.enable) {
    text = ''
      auth       required                    pam_shells.so
      auth       requisite                   pam_nologin.so
      auth       requisite                   pam_faillock.so      preauth
      auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
      auth       optional                    pam_permit.so
      auth       required                    pam_env.so
      auth       [success=ok default=1]      ${pkgs.gdm}/lib/security/pam_gdm.so
      auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so

      account    include                     login

      password   required                    pam_deny.so

      session    include                     login
      session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    '';
  };

  # Don't touch this
  system.stateVersion = "24.11";
}
