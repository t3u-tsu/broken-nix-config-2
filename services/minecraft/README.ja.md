# Minecraft ネットワーク構成

このディレクトリでは、Velocity プロキシと Paper バックエンドサーバーによる Minecraft ネットワークを管理しています。

## 構成概要

- **プロキシ (Velocity)**: `proxy.nix`
  - ポート: `25565`
  - ドメインベースのルーティング:
    - `mc.t3u.uk` -> `lobby`
    - `nitac23s.mc.t3u.uk` -> `nitac23s`
- **バックエンド (Lobby)**: `servers/lobby.nix`
  - ポート: `25566`
  - 待機ロビー（Voidワールド）。
- **バックエンド (nitac23s)**: `servers/nitac23s.nix`
  - ポート: `25567`
  - メインサバイバルサーバー。

## プラグイン管理 (nvfetcher)

プラグイン（ViaVersion, ViaBackwards）は `plugins/` ディレクトリで **nvfetcher** を使用して管理されています。これにより、最新のハッシュ値を自動取得し、宣言的にプラグインを最新に保つことができます。

- **更新コマンド**:
  ```bash
  nix shell nixpkgs#nvfetcher -c nvfetcher -c services/minecraft/plugins/nvfetcher.toml -o services/minecraft/plugins/generated.nix
  ```

## Lobby サーバーの仕様
- **地形**: Void（一切のブロックがない空気のみのワールド）
- **バイオーム**: `minecraft:the_void`
- **Mob**: 自然スポーン、初期配置ともに完全に無効化 (Peaceful + Spawn Limits 0)
- **モード**: アドベンチャーモード固定
- **構造物**: 生成なし
