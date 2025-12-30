{ config, pkgs, ... }:

{
  services.minecraft-servers.servers.lobby = {
    enable = true;
    package = pkgs.paperServers.paper; # 常にその時点の最新安定版を指す属性

    jvmOpts = "-Xms2G -Xmx4G";

    serverProperties = {
      server-port = 25566;
      online-mode = false; # Velocity が認証を行うため false
      white-list = false;
      gamemode = "adventure";
      force-gamemode = true;
      level-type = "flat";
      spawn-monsters = false;
      spawn-animals = false;
      spawn-npcs = false;
    };

    symlinks = {
      "plugins/ViaVersion.jar" = pkgs.fetchurl {
        url = "https://github.com/ViaVersion/ViaVersion/releases/download/5.2.1/ViaVersion-5.2.1.jar";
        sha256 = "sha256-Kx83C9gb5gVd0ebM5GkmvYUrI15kSNZr2myV+6yWKsM=";
      };
      "plugins/ViaBackwards.jar" = pkgs.fetchurl {
        url = "https://github.com/ViaVersion/ViaBackwards/releases/download/5.2.1/ViaBackwards-5.2.1.jar";
        sha256 = "sha256-2wbj6CvMu8hnL260XLf8hqhr6GG/wxh+SU8uX5+x8NY=";
      };
      "velocity-forwarding.secret" = config.sops.secrets.minecraft_forwarding_secret.path;
    };

    # files = { ... } は preStart で手動生成するため削除
  };

  # nix-minecraft が生成するサービスを拡張
  systemd.services.minecraft-server-lobby = {
    preStart = ''
      # ワールドリセットのチェック
      if [ -f ".reset_world" ]; then
        echo "Resetting world data as requested..."
        rm -rf world world_nether world_the_end
        rm .reset_world
      fi

      # ディレクトリの準備
      mkdir -p config
      
      # sops の秘密鍵を読み込む
      SECRET=$(cat ${config.sops.secrets.minecraft_forwarding_secret.path})
      
      # 設定ファイルが Nix Store へのリンクなどの場合、書き換えられないため
      # 一旦削除または退避して、実ファイルとして配置・置換する
      if [ -L "config/paper-global.yml" ]; then
        rm "config/paper-global.yml"
      fi

      # テンプレートファイル（nixで生成されたもの）からコピーしてくる必要があるが
      # nix-minecraft の files 属性は既に symlink を作成しようとしているため
      # 手動でファイルを生成するか、sed の挙動を調整する。
      # ここでは、直接ファイルを生成するアプローチをとります。
      cat <<EOF > config/paper-global.yml
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
