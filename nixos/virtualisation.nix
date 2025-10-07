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
        vhostUserPackages = with pkgs; [virtiofsd];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

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

  # Broken
  # virtualisation.virtualbox.host.enable = true; # Oracle VirtualBox

  users.users.${config.var.username}.extraGroups = [
    "libvirtd"
    "vboxusers" # VirtualBox
  ];
}
