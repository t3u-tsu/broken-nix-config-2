{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.my.home.desktop.niri;
in {
  config = mkIf cfg.enable {
    # Launcher (Fuzzel)
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=12";
          terminal = "alacritty";
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
