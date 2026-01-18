# Minecraft Discord Bridge サービス

このディレクトリでは、Go 製の [minecraft-discord-bridge](https://github.com/t3u-tsu/minecraft-discord-bridge) を NixOS 上でサービスとして動かすためのモジュールを管理しています。

## 構成概要

- **`default.nix`**: 
  - GitHub リポジトリからソースを直接フェッチしてビルドします。
  - 秘密情報を `sops-nix` から環境変数経由で注入します。
  - Unix ドメインソケットおよび Systemd サービスの設定を行います。

## 設定方法

各ホスト（現在は `shosoin-tan`）の設定ファイルで以下のように有効化します：

```nix
services.minecraft-discord-bridge = {
  enable = true;
  settings = {
    discord.admin_guild_id = "1457...";
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
```

## 運用コマンド (ローカル)

サーバー上で直接操作する場合（※tmux ではなく nc を使用します）：
```bash
echo 'status' | sudo nc -U -N /run/minecraft-discord-bridge/bridge.sock
```

## セキュリティ
- **機密情報の注入**: RCON パスワードや Bot トークンは `environmentFile` を通じて安全に渡されます。各サーバーの RCON パスワードは `sops.templates` を用いて動的に環境変数へ変換・注入されます。
- **権限**: サービスは `minecraft` ユーザーで実行され、不要な特権を持ちません。
