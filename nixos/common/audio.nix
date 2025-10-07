{
  config,
  lib,
  ...
}: let
  cfg = config.system.audio;
  enabled = cfg.enable;
in {
  options.system.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Audio on System";
    };
  };

  config = lib.mkIf enabled {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
