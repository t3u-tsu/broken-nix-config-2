{ config, pkgs, lib, ... }:

let
  # 自動生成されたプラグイン情報を読み込む
  plugins = pkgs.callPackage ../plugins/generated.nix { };
in
{
  services.minecraft-servers.servers.nitac23s = {
    enable = true;
    package = pkgs.paperServers.paper; # 常に最新を使用

    jvmOpts = "-Xms2G -Xmx4G"; # メイン鯖なので少し多めに割り当て

    # server.properties is manually managed in preStart to securely inject secrets
    serverProperties = {
      server-port = 25567;
      max-players = 30;
      online-mode = false; # Velocity 経由
      white-list = true;
      allow-flight = true;
      difficulty = "hard";
      gamemode = "survival";
      enable-command-block = true;
      generate-structures = true;
      view-distance = 12;
      enable-rcon = true;
      "rcon.port" = 25575;
    };

    files = {
      "ops.json".value = [
        {
          uuid = "7e954690-4166-4c66-b7bc-3f28bd01641f";
          name = "coutmeow";
          level = 4;
          bypassesPlayerLimit = false;
        }
      ];
      # 既存のワールド設定を継承 (必要に応じて)
      "config/paper-world-defaults.yml".value = {
        anticheat.anti-xray.enabled = false;
        # 他の設定はデフォルトを使用
      };
    };

    # プラグインの導入
    symlinks = {
      "plugins/ViaVersion.jar" = plugins.viaversion.src;
      "plugins/ViaBackwards.jar" = plugins.viabackwards.src;
      "plugins/GSit.jar" = plugins.gsit.src;
      "plugins/LunaChat.jar" = plugins.lunachat.src;
      # 追加のプラグイン (LunaChat 等は必要に応じてバイナリを指定)
    };
  };

  # シークレットの動的注入
  systemd.services.minecraft-server-nitac23s = {
    # Fix udev warning
    environment.LD_LIBRARY_PATH = "${lib.makeLibraryPath [ pkgs.udev ]}";

    preStart = lib.mkAfter ''
      # Wait a tiny bit to ensure the module has finished its setup
      sleep 1
      
      # RCON Password
      RCON_PASS=$(cat ${config.sops.secrets.nitac23s_rcon_password.path})

      # Ensure RCON password is set in server.properties
      # We append it to the end, which will override any previous value in the file
      echo "rcon.password=$RCON_PASS" >> server.properties
      chown minecraft:minecraft server.properties
      chmod 600 server.properties

      mkdir -p config
      SECRET=$(cat ${config.sops.secrets.minecraft_forwarding_secret.path})
...
}