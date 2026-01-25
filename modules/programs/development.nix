# Development tools module
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.programs.development;
in {
  options.programs.development = {
    enable = lib.mkEnableOption "Development tools";
    
    docker.enable = lib.mkEnableOption "Docker containerization";
    devenv.enable = lib.mkEnableOption "Devenv development environments";
    virtualisation.enable = lib.mkEnableOption "Virtualisation (QEMU/KVM)";
  };

  config = lib.mkIf cfg.enable {
    # Docker
    virtualisation.docker = lib.mkIf cfg.docker.enable {
      enable = true;
    };

    # Virtualisation
    virtualisation.libvirtd = lib.mkIf cfg.virtualisation.enable {
      enable = true;
    };
    programs.virt-manager.enable = cfg.virtualisation.enable;

    # User groups - combine docker and libvirtd groups
    users.users.${config.username}.extraGroups = 
      lib.optional cfg.docker.enable "docker"
      ++ lib.optionals cfg.virtualisation.enable [ "libvirtd" "kvm" ];
  };
}
