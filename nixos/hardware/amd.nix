{pkgs, ...}: {
  boot.initrd.kernelModules = ["amdgpu"];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr.icd
        clinfo
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  services.xserver.videoDrivers = ["amdgpu"];

  # Force RADV
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
