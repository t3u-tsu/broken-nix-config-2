{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.home.desktop.dev-tools.neovim;
in {
  options.my.home.desktop.dev-tools.neovim = {
    enable = mkEnableOption "Neovim text editor";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      # Base configuration can be added here
    };
  };
}
