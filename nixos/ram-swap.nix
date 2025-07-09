# Virtual RAM / RAM Compression
{config, ...}: {
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
}
