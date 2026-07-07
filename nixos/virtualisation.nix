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
        verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/rtc", "/dev/hpet",
            "/dev/vfio/vfio", "/dev/dri/renderD128"
          ]
        '';
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
    "kvm"
    "render"
    "video"
  ];

  virtualisation.vmVariant = {
    # VM-specific hardware overrides for testing the configuration locally
    virtualisation.memorySize = 8192; # 8 GB RAM for a smooth desktop environment
    virtualisation.cores = 4;          # 4 CPU cores
    virtualisation.qemu.options = [
      "-vga none"
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
    services.qemuGuest.enable = true;
  };
}
