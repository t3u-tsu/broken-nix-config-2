{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.services.minecraft-discord-bridge;
  format = pkgs.formats.toml { };
  configFile = format.generate "bridge-config.toml" cfg.settings;
  
  # Flake input からパッケージを取得
  bridgePkg = inputs.minecraft-discord-bridge.packages.${pkgs.system}.default;
in
{
  options.services.minecraft-discord-bridge = {
    enable = mkEnableOption "Minecraft Discord Bridge";
    
    settings = mkOption {
      type = format.type;
      default = { };
      description = "Configuration for the bridge (TOML format)";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File containing environment variables (secrets)";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.minecraft-discord-bridge = {
      description = "Minecraft Discord Bridge";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Replace placeholders in config file
        # We create a writable copy of the config file in the state directory
        cp ${configFile} config.toml
        chmod 600 config.toml
        
        if [ -f "${config.sops.secrets.discord_admin_guild_id.path}" ]; then
          ADMIN_ID=$(cat ${config.sops.secrets.discord_admin_guild_id.path})
          sed -i "s/@ADMIN_GUILD_ID@/$ADMIN_ID/" config.toml
        fi
      '';

      serviceConfig = {
        ExecStart = "${bridgePkg}/bin/minecraft-discord-bridge -c /var/lib/minecraft-discord-bridge/config.toml";
        Restart = "always";
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
        StateDirectory = "minecraft-discord-bridge";
        RuntimeDirectory = "minecraft-discord-bridge";
        WorkingDirectory = "/var/lib/minecraft-discord-bridge";
        User = "minecraft";
        Group = "minecraft";
      };
    };
  };
}
