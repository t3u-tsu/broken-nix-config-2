{ pkgs, ... }:

{
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
}
