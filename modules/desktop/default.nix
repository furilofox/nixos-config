# Desktop environment modules
{lib, ...}: {
  imports = [
    ./niri
    ./hyprland
    ./noctalia
  ];

  options.desktop = {
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Monitor output name (e.g., DP-1, HDMI-A-1)";
          };
          width = lib.mkOption {
            type = lib.types.int;
            description = "Resolution width";
          };
          height = lib.mkOption {
            type = lib.types.int;
            description = "Resolution height";
          };
          refresh = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "Refresh rate in Hz";
          };
          position = lib.mkOption {
            type = lib.types.str;
            default = "0,0";
            description = "Position as x,y";
          };
          scale = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
            description = "Display scale factor";
          };
        };
      });
      default = [];
      description = "Monitor configuration";
    };
  };
}
