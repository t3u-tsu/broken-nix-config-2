{ config, pkgs, ... }:

{
  services.minecraft-discord-bridge = {
    enable = true;
    settings = {
      # Values are overridden by environment variables in sops
      discord.admin_guild_id = "SET_VIA_ENV";
      database.path = "/var/lib/minecraft-discord-bridge/bridge.db";
      bridge.socket_path = "/run/minecraft-discord-bridge/bridge.sock";
      servers.nitac23s = {
        network = "tcp";
        address = "127.0.0.1:25575";
        whitelist_path = "/srv/minecraft/nitac23s/whitelist.json";
      };
    };
    environmentFile = config.sops.secrets.discord_bridge_env.path;
  };

  sops.secrets.discord_bridge_env = {
    owner = "minecraft";
  };
}
