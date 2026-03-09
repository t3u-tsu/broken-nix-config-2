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
        # Dracula Color Scheme
        colors = {
          primary = {
            background = "#282a36";
            foreground = "#f8f8f2";
            bright_foreground = "#ffffff";
          };
          cursor = {
            text = "CellBackground";
            cursor = "CellForeground";
          };
          normal = {
            black = "#21222c";
            red = "#ff5555";
            green = "#50fa7b";
            yellow = "#f1fa8c";
            blue = "#bd93f9";
            magenta = "#ff79c6";
            cyan = "#8be9fd";
            white = "#f8f8f2";
          };
          bright = {
            black = "#6272a4";
            red = "#ff6e6e";
            green = "#69ff94";
            yellow = "#ffffa5";
            blue = "#d6acff";
            magenta = "#ff92df";
            cyan = "#a4ffff";
            white = "#ffffff";
          };
        };
      };
    };
  };
}
