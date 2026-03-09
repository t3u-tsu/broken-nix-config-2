{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.home.desktop.theme;
in {
  options.my.home.desktop.theme = {
    enable = mkEnableOption "System-wide Dark Mode and Desktop Appearance";
  };

  config = mkIf cfg.enable {
    # GTK Appearance
    gtk = {
      enable = true;
      theme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
      };
      iconTheme = {
        name = "breeze-dark";
        package = pkgs.kdePackages.breeze-icons;
      };
    };

    # Qt Appearance Integration
    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "breeze";
    };
  };
}
