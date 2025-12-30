{ config, pkgs, lib, ... }:

{
  services.minecraft-servers.servers.nitac23s = {
    enable = true;
    package = pkgs.paperServers.paper; # 常に最新を使用

    jvmOpts = "-Xms2G -Xmx4G"; # メイン鯖なので少し多めに割り当て

    serverProperties = {
      server-port = 25567;
      online-mode = false; # Velocity 経由
      white-list = true;
      allow-flight = true;
      difficulty = "hard";
      gamemode = "survival";
      enable-command-block = true;
      generate-structures = true;
      view-distance = 12;
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
      # ViaVersion 5.2.1 is incompatible with 1.21.11. Disabled until updated.
      # "plugins/ViaVersion.jar" = pkgs.fetchurl {
      #   url = "https://github.com/ViaVersion/ViaVersion/releases/download/5.2.1/ViaVersion-5.2.1.jar";
      #   sha256 = "sha256-Kx83C9gb5gVd0ebM5GkmvYUrI15kSNZr2myV+6yWKsM=";
      # };
      # "plugins/ViaBackwards.jar" = pkgs.fetchurl {
      #   url = "https://github.com/ViaVersion/ViaBackwards/releases/download/5.2.1/ViaBackwards-5.2.1.jar";
      #   sha256 = "sha256-2wbj6CvMu8hnL260XLf8hqhr6GG/wxh+SU8uX5+x8NY=";
      # };
      # 追加のプラグイン (LunaChat 等は必要に応じてバイナリを指定)
    };
  };

  # シークレットの動的注入
  systemd.services.minecraft-server-nitac23s = {
    # Fix udev warning
    environment.LD_LIBRARY_PATH = "${lib.makeLibraryPath [ pkgs.udev ]}";

    preStart = ''
      mkdir -p config
      SECRET=$(cat ${config.sops.secrets.minecraft_forwarding_secret.path})
      if [ -L "config/paper-global.yml" ]; then rm "config/paper-global.yml"; fi
      
      # paper-global.yml の生成とシークレット埋め込み
      cat <<EOF > config/paper-global.yml
# Fix global config version warning
config-version: 31
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: $SECRET
EOF
      chown minecraft:minecraft config/paper-global.yml
      chmod 600 config/paper-global.yml
    '';
  };
}