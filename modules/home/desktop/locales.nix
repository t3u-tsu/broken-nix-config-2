{ config, lib, ... }:

with lib;
let
  cfg = config.my.home.desktop.locales;
in {
  options.my.home.desktop.locales = {
    enable = mkEnableOption "User-specific locale settings";
  };

  config = mkIf cfg.enable {
    home.language.base = "ja_JP.UTF-8";
  };
}
