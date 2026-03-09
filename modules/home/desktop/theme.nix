{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.home.desktop.theme;
in {
  options.my.home.desktop.theme = {
    enable = mkEnableOption "System-wide Dracula Theme and Desktop Appearance";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dracula-theme
      dracula-icon-theme
      dracula-qt5-theme
    ];

    # GTK Appearance (Dracula)
    gtk = {
      enable = true;
      theme = {
        name = "Dracula";
        package = pkgs.dracula-theme;
      };
      iconTheme = {
        name = "Dracula";
        package = pkgs.dracula-icon-theme;
      };
    };

    # Qt Appearance Integration
    qt = {
      enable = true;
      platformTheme.name = "gtk"; 
      style.name = "adwaita-dark";
    };
  };
}
