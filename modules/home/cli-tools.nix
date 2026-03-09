{ pkgs, ... }:

{
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
  };

  home.shellAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    cat = "bat";
    grep = "ripgrep";
  };
}
