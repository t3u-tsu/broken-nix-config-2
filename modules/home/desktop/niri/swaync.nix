{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.my.home.desktop.niri;
in {
  config = mkIf cfg.enable {
    # If the HM module exists, use it. Otherwise, fallback to packages.
    home.packages = [ pkgs.swaynotificationcenter ];
  };
}
