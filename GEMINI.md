# NixOS設定構築のコンテキスト

## 目的

`.` ディレクトリにて、Orange Pi Zero3 (`torii-chan`) 向けのNixOS設定を構築中。最終目標はSDカードイメージの生成と実機へのデプロイです。

## 現在の状況 (2025-12-29)

**実機起動 & WireGuard接続成功。SD運用構成のデプロイ試行中。**

### 達成したマイルストーン

1.  **実機セットアップ完了:**
    - SDイメージ書き込み & 起動。
    - `key.txt` 配置 & WireGuard サービス起動（`sops-nix` 正常動作）。
    - 管理PCからの VPN 接続 (`10.0.0.1`) 成功。
2.  **新構成の追加:**
    - `torii-chan-sd-live`: HDDなしでSDカード運用のまま、最新設定（セキュリティ、ユーザー等）を反映するための構成を追加。
    - `hosts/torii-chan/fs-sd.nix`: SDカード用パーティション設定を作成。

### 現在の課題（デプロイエラー）

管理PCから `nixos-rebuild` で `torii-chan-sd-live` をデプロイしようとすると、署名エラー (`lacks a signature by a trusted key`) が発生。
- **原因:** 実機のNixデーモンが管理PC（ビルド元）を信頼していない、または `t3u` ユーザーが信頼されていないため。
- **対策:** 実機の `/etc/nix/nix.conf` に `trusted-users = root t3u` を追加してデーモンを再起動する。

### 次のステップ

1.  **実機設定変更:** SSHで入り、Nixの信頼ユーザー設定を変更。
2.  **デプロイ再試行:** `torii-chan-sd-live` を適用し、SSHポート制限等の本番セキュリティを有効化。
3.  **HDD移行:** HDD入手後、データコピーと `torii-chan` 構成への切り替え。

### デプロイコマンド（SD運用版）
`nix --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-rebuild -- switch --flake .#torii-chan-sd-live --target-host t3u@192.168.0.128 --sudo`

