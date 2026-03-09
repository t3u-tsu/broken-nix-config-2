{ config, pkgs, lib, ... }:

{
  home-manager.users.${config.my.user.name} = {
    home.stateVersion = config.system.stateVersion;
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

    # Command-not-found & comma (,) integration
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };
}
