{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    obsidian
    vlc
    gimp
    lazygit
    mangohud
  ];

  programs.firefox.enable = true;
}
