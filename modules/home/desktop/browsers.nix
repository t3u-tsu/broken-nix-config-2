{ config, osConfig, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.my.home.desktop.browsers;
in {
  options.my.home.desktop.browsers = {
    enable = mkEnableOption "Web browsers";
    zen.enable = mkOption {
      type = types.bool;
      default = true;
    };
    chromium.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional cfg.chromium.enable pkgs.chromium;

    programs.zen-browser = mkIf cfg.zen.enable {
      enable = true;
      # Create a default profile named after the user
      profiles.${osConfig.my.user.name} = {
        isDefault = true;
        settings = {
          # Recommended settings for a smoother experience
          "extensions.autoDisableScopes" = 0;
          "browser.aboutConfig.showWarning" = false;
          "browser.shell.checkDefaultBrowser" = false;
        };
      };
    };
  };
}