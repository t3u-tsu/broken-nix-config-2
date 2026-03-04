{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./proxy.nix
    ./servers
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true; # 同意
  };

  # Automatically register nvfetcher update task if auto-update is enabled
  my.autoUpdate.nvfetcher = [
    (inputs.self.lib.autoUpdate.mkNvfetcherTask "services/minecraft/plugins")
  ];
}
