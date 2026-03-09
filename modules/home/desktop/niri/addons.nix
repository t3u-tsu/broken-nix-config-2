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

    # Additional GUI tools
    home.packages = with pkgs; [
      nautilus
      adwaita-icon-theme
      hyprpolkitagent
    ];
  };
}
