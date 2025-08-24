{pkgs, ...}: {
  boot.initrd.kernelModules = ["amdgpu"];
  
  # Enable early KMS for proper display initialization
  # Added freesync_video and vrr parameters for mixed refresh rate support
  boot.kernelParams = [ 
    "amdgpu.dc=1" 
    "amdgpu.dpm=1"
    "amdgpu.freesync_video=1"  # Enable FreeSync/VRR optimization
    "amdgpu.vrr=1"              # Enable Variable Refresh Rate
    "amdgpu.ppfeaturemask=0xffffffff"  # Enable all power features
    # Removed forced video modes - let driver negotiate
    "amdgpu.mst=0"              # Disable MST to avoid bandwidth sharing issues
    "amdgpu.audio=0"            # Disable HDMI audio to save bandwidth
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        clinfo
        # Add vulkan packages for better GPU support
        vulkan-tools
        vulkan-validation-layers
      ];
    };
    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  services.xserver.videoDrivers = ["amdgpu"];

  # Environment variables for better AMD GPU handling
  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    # Disable GPU recovery for stability with mixed refresh rates
    HSA_ENABLE_SDMA = "0";
    # Force high performance mode
    AMD_DEBUG = "nodcc";
  };
}
