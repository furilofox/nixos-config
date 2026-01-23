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

      extraConfig.pipewire = {
        "92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 1024;
            "default.clock.max-quantum" = 4096;
          };
        };
        "99-input-denoising" = {
          "context.properties" = {
            "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
          };
        };
      };
    };
  };
}
