{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.my.home.desktop.niri;
in {
  imports = [
    inputs.noctalia-shell.homeModules.default
  ];

  config = mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {
        bar = {
          position = "top";
          floating = true;
          backgroundOpacity = 0.8;
        };
        # Dracula-like colors can be set here if noctalia supports them
        colorSchemes = {
          darkMode = true;
          useWallpaperColors = false; # Set to false to force dracula-ish colors if needed
        };
      };
    };
  };
}
