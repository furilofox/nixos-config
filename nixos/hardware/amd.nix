{pkgs, ...}: {
  boot.initrd.kernelModules = ["amdgpu"];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        clinfo
      ];
    };
    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  services.xserver.videoDrivers = ["amdgpu"];

  # Force RADV
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
