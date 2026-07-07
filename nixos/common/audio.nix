{
  config,
  lib,
  pkgs,
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

    deepfilter = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable DeepFilterNet noise suppression (creates a virtual 'Noise Canceling Source' microphone)";
    };
  };

  config = lib.mkIf enabled (lib.mkMerge [
    {
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
              "default.clock.allowed-rates" = [44100 48000 88200 96000];
            };
          };
        };
      };
    }

    # DeepFilterNet noise suppression + noise gate via PipeWire LADSPA filter-chain
    (lib.mkIf cfg.deepfilter {
      environment.systemPackages = [pkgs.deepfilternet];

      services.pipewire.extraLadspaPackages = [
        pkgs.deepfilternet
        pkgs.ladspaPlugins # swh-plugins: provides noise gate
      ];

      services.pipewire.extraConfig.pipewire."98-deepfilternet" = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Noise Canceling Source";
              "media.name" = "Noise Canceling Source";
              "filter.graph" = {
                nodes = [
                  # Stage 1: DeepFilterNet — neural noise suppression
                  {
                    type = "ladspa";
                    name = "deepfilternet";
                    plugin = "libdeep_filter_ladspa";
                    label = "deep_filter_mono";
                    control = {
                      "Attenuation Limit" = 100;
                      # Lower thresholds = model processes more aggressively on quieter signals
                      "Min processing threshold" = -20;
                      "Max ERB processing threshold" = 30;
                      "Max DF processing threshold" = 40;
                      # Post-filter: slightly over-attenuates residual noise (range 0–0.05)
                      "Post Filter Beta" = 0.05;
                    };
                  }
                  # Stage 2: Noise gate — silences residual breathing/sniffing between speech
                  {
                    type = "ladspa";
                    name = "gate";
                    plugin = "gate_1410";
                    label = "gate";
                    control = {
                      # Only open for speech-level signals (raise if still hearing noise)
                      "Threshold (dB)" = -36;
                      "Attack (ms)" = 5;
                      "Hold (ms)" = 150;
                      "Decay (ms)" = 250;
                      "Range (dB)" = -90;
                      # 0 = gate mode
                      "Output select (-1 = key listen, 0 = gate, 1 = bypass)" = 0;
                    };
                  }
                ];
                links = [
                  {
                    output = "deepfilternet:Audio Out";
                    input = "gate:Input";
                  }
                ];
              };
              "capture.props" = {
                "node.name" = "effect_input.deepfilternet";
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "effect_output.deepfilternet";
                "media.class" = "Audio/Source";
              };
            };
          }
        ];
      };
    })
  ]);
}
