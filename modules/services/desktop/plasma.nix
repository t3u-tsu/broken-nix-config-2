{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.my.services.desktop.plasma;
in {
  options.my.services.desktop.plasma = {
    enable = mkEnableOption "KDE Plasma desktop environment";
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Wayland support
    services.displayManager.sddm.wayland.enable = true;

    # Localization
    i18n.defaultLocale = "ja_JP.UTF-8";
    time.timeZone = "Asia/Tokyo";

    # Plasma basic tools
    environment.systemPackages = with pkgs.kdePackages; [
      konsole
      dolphin
      kate
    ];
  };
}
