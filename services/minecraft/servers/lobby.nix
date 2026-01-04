{ config, pkgs, lib, ... }:

let
  # 自動生成されたプラグイン情報を読み込む
  plugins = pkgs.callPackage ../plugins/generated.nix { };
in
{
  services.minecraft-servers.servers.lobby = {
    enable = true;
    package = pkgs.paperServers.paper; # 常にその時点の最新安定版を指す属性

    jvmOpts = "-Xms512M -Xmx1G";

    serverProperties = {
      server-port = 25566;
      max-players = 30;
      online-mode = false; # Velocity が認証を行うため false
      white-list = false;
      gamemode = "adventure";
      force-gamemode = true;
      difficulty = "peaceful";
      level-type = "flat";
      level-seed = "";
      # スーパーフラットのカスタマイズ（空気のみ、バイオームは the_void）
      generator-settings = "{\"layers\": [{\"block\": \"minecraft:air\", \"height\": 1}], \"biome\": \"minecraft:the_void\"}";
      generate-structures = false; # 構造物を生成しない
      spawn-monsters = false;
      spawn-animals = false;
      spawn-npcs = false;
      allow-flight = true;
    };

    symlinks = {
      "plugins/ViaVersion.jar" = plugins.viaversion.src;
      "plugins/ViaBackwards.jar" = plugins.viabackwards.src;
      "plugins/GSit.jar" = plugins.gsit.src;
      "plugins/LunaChat.jar" = plugins.lunachat.src;
      "velocity-forwarding.secret" = config.sops.secrets.minecraft_forwarding_secret.path;
    };

    files = {
      "config/paper-world-defaults.yml".value = {
...
  # nix-minecraft が生成するサービスを拡張
  systemd.services.minecraft-server-lobby = {
    # Fix udev warning
    environment.LD_LIBRARY_PATH = "${lib.makeLibraryPath [ pkgs.udev ]}";

    preStart = ''
      # Handle LunaChat config
      if [ -f plugins/LunaChat/config.yml ]; then
        sed -i 's/japanize: false/japanize: true/' plugins/LunaChat/config.yml
        sed -i 's/japanizeType: none/japanizeType: GoogleIME/' plugins/LunaChat/config.yml
        sed -i 's/japanizeDisplayLine: 0/japanizeDisplayLine: 2/' plugins/LunaChat/config.yml
      fi

      # ワールドおよびプレイヤーデータリセットのチェック
      if [ -f ".reset_world" ]; then
        echo "Resetting world and player data as requested..."
        rm -rf world*
        rm -f usercache.json
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
