{ config, pkgs, ... }:

{
  services.minecraft-discord-bridge = {
    enable = true;
    settings = {
      discord.admin_guild_id = "1324074411111153714";
      database.path = "/var/lib/minecraft-discord-bridge/bridge.db";
      bridge.socket_path = "/run/minecraft-discord-bridge/bridge.sock";
      servers.nitac23s = {
        network = "tcp";
        address = "127.0.0.1:25575";
      };
    };
    environmentFile = config.sops.secrets.discord_bridge_env.path;
  };

  sops.secrets.discord_bridge_env = {};
}
