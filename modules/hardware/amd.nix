# AMD GPU hardware module
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hardware.amd;
in {
  options.hardware.amd = {
    enable = lib.mkEnableOption "AMD GPU support";

    freesync = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable FreeSync/VRR support";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams =
      [
        "amdgpu.dc=1"
        "amdgpu.dpm=1"
        "amdgpu.ppfeaturemask=0xffffffff"
        "amdgpu.mst=0"
        "amdgpu.audio=0"
      ]
      ++ lib.optionals cfg.freesync [
        "amdgpu.freesync_video=1"
        "amdgpu.vrr=1"
      ];

    hardware = {
      amdgpu.initrd.enable = true; # sets boot.initrd.kernelModules = ["amdgpu"];
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
          clinfo
          vulkan-tools
          vulkan-validation-layers
        ];
      };
    };

    services.xserver.videoDrivers = ["amdgpu"];

    environment.variables = {
      AMD_VULKAN_ICD = "RADV"; # Force RADV
      HSA_ENABLE_SDMA = "0";
      AMD_DEBUG = "nodcc";
    };
  };
}
