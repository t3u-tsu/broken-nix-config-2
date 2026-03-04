{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    direnv
    eza
    fd
    file
    fzf
    git
    ripgrep
    tealdeer
    tmux
    vim
    which
    zoxide
  ];
}
