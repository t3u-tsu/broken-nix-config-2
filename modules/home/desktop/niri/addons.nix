{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.my.home.desktop.niri;
in {
  config = mkIf cfg.enable {
    # Notifications (SwayNC) - We will use the package and spawn it
    # services.swaync is not available in standard HM, using package instead

    # Clipboard History
    services.cliphist.enable = true;

    # OSD (swayosd)
    services.swayosd.enable = true;

    # Network Manager Applet
    services.network-manager-applet.enable = true;

    # Bluetooth Applet
    services.blueman-applet.enable = true;

    # Additional GUI tools
    home.packages = with pkgs; [
      nautilus
      gnome-terminal
      adwaita-icon-theme
      wlogout
      hyprpolkitagent
      swaynotificationcenter
    ];
  };
}
