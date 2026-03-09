{ pkgs, inputs, config, lib, ... }:

with lib;
let
  cfg = config.my.services.desktop.niri;
in {
  # Import the niri-flake NixOS module at the top level
  imports = [ 
    inputs.niri.nixosModules.niri 
  ];

  options.my.services.desktop.niri = {
    enable = mkEnableOption "Niri scrollable-tiling Wayland compositor";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    # Necessary for screen sharing and other desktop features
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      config.common.default = [ "gnome" "gtk" ];
    };

    services.dbus.enable = true;
  };
}
