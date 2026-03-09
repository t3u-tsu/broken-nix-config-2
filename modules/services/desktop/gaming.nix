{ pkgs, ... }:

{
  # Steam configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # GameMode configuration
  programs.gamemode.enable = true;

  # Ensure user can use MangoHud and other performance tools
  environment.systemPackages = with pkgs; [
    mangohud
    gperftools
  ];
}
