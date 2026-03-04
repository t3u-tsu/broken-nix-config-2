{ config, pkgs, lib, ... }:

{
  home-manager.users.t3u = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -a";
        cat = "bat";
        grep = "ripgrep";
      };
      history = {
        size = 10000;
        path = "$HOME/.zsh_history";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" "direnv" ];
        theme = "robbyrussell";
      };
    };

    programs.bat.enable = true;
    programs.eza.enable = true;
    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
