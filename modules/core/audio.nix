# Audio module with PipeWire configuration
{ config, lib, ... }:
let
  cfg = config.audio;
in {
  options.audio = {
    enable = lib.mkEnableOption "PipeWire audio system";

    lowLatency = lib.mkEnableOption "Low-latency audio configuration for production";

    jack = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable JACK audio support";
    };
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = cfg.jack;

      extraConfig.pipewire = lib.mkIf cfg.lowLatency {
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
