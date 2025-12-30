# Minecraft ネットワーク構成

このディレクトリでは、Velocity プロキシと Paper バックエンドサーバーによる Minecraft ネットワークを管理しています。

## 構成概要

- **プロキシ (Velocity)**: `proxy.nix`
  - ポート: `25565`
  - 認証とサーバー間転送を担当。
  - `modern` 転送モードを使用。
- **バックエンド (Lobby)**: `servers/lobby.nix`
  - ポート: `25566`
  - 待機ロビー。
  - バージョン: Latest (PaperMC)
  - プラグイン: ViaVersion, ViaBackwards

## セキュリティと秘密情報

### プレイヤー情報の転送 (Forwarding Secret)
Velocity と Lobby 間の通信を保護するため、共通の秘密鍵（Secret）を使用しています。Nix Store に秘密鍵が露出するのを防ぐため、以下の仕組みを採用しています。

1. **sops-nix**: 秘密鍵を `secrets.yaml` で暗号化管理。
2. **動的インジェクション**: `lobby` サーバーの起動直前 (`preStart`) に、`sops` で復号された鍵を `paper-global.yml` に `sed` で埋め込みます。

## 運用操作

### ワールドおよびデータのフルリセット
地形生成設定の変更などを反映させるためにデータを初期化したい場合、以下の手順を実行します。

1. **リセットフラグの作成**:
   ```bash
   ssh -t <target-host> "sudo touch /srv/minecraft/lobby/.reset_world && sudo chown minecraft:minecraft /srv/minecraft/lobby/.reset_world"
   ```
2. **デプロイまたはサービス再起動**:
   `nixos-rebuild switch` を実行すると、起動スクリプトがフラグを検知して `world*` ディレクトリと `usercache.json` を削除してから起動します。

### コンソールへのアクセス
```bash
ssh -t <target-host> "sudo tmux -S /run/minecraft/lobby.sock attach"
```
脱出するには `Ctrl+b` -> `d` です。

## Lobby サーバーの仕様
- **地形**: スーパーフラット (地面高さ Y=64)
- **Mob**: 自然スポーン、初期配置ともに完全に無効化 (Peaceful + Spawn Limits 0)
- **モード**: アドベンチャーモード固定
- **構造物**: 生成なし
