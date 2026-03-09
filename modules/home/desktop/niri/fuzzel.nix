{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.my.home.desktop.niri;
in {
  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=12";
          terminal = "alacritty";
          width = 40;
          horizontal-pad = 20;
          vertical-pad = 10;
          inner-pad = 5;
        };
        colors = {
          background = "282a36ff";
          text = "f8f8f2ff";
          match = "8be9fdff";
          selection = "44475aff";
          selection-text = "f8f8f2ff";
          border = "bd93f9ff";
        };
      };
    };
  };
}
