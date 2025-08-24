{pkgs, ...}: {
  boot.initrd.kernelModules = ["amdgpu"];
  
  # Enable early KMS for proper display initialization
  boot.kernelParams = [ "amdgpu.dc=1" "amdgpu.dpm=1" ];

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
