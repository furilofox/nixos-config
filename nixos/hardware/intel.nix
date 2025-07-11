{pkgs, ...}: {
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
}
