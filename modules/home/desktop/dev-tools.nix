{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.home.desktop.dev-tools;
in {
  options.my.home.desktop.dev-tools = {
    enable = mkEnableOption "Development tools";
    vscode.enable = mkOption {
      type = types.bool;
      default = false;
    };
    neovim.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lazygit
    ];

    programs.neovim = mkIf cfg.neovim.enable {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.vscode = mkIf cfg.vscode.enable {
      enable = true;
      package = pkgs.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-ceintl.vscode-language-pack-ja
      ];
    };
  };
}
