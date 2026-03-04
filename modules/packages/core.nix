{ config, lib, ... }:

with lib;
let
  cfg = config.my.packages.core;
in {
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bat direnv eza fd file fzf git ripgrep tealdeer tmux vim which zoxide
    ];
    
    # Zsh configuration via NixOS (System-wide)
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
    
    # Home-manager shell integration will be added in modules/shell
  };
}
