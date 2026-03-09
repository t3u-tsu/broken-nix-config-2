{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.home.desktop.terminal.alacritty;
in {
  options.my.home.desktop.terminal.alacritty = {
    enable = mkEnableOption "Alacritty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
          size = 11;
        };
        window = {
          opacity = 0.95;
          padding = { x = 6; y = 6; };
        };
      };
    };
  };
}