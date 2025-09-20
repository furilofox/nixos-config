{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
        vhostUserPackages = with pkgs; [virtiofsd];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  users.users.${config.var.username}.extraGroups = ["libvirtd"];

  environment.systemPackages = with pkgs; [
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    virtiofsd
  ];

  services.spice-vdagentd.enable = true;
}
