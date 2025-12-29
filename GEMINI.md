# NixOS設定構築のコンテキスト

## 目的

`.` ディレクトリにて、Orange Pi Zero3 (`torii-chan`) 向けのNixOS設定を構築中。最終目標はSDカードイメージの生成と実機へのデプロイです。

## 現在の状況 (2025-12-29)

**SDイメージビルド完了。WireGuard Peer設定済み。**

### 達成したマイルストーン

1.  **SD/HDD構成の確立:** `torii-chan-sd` (初期) / `torii-chan` (運用) の構成済み。
2.  **サービス設定:** DDNS, WireGuard (サーバー) 設定済み。
3.  **シークレット:** `secrets/secrets.yaml` に全必要キー設定済み。
4.  **WireGuardクライアント設定 (管理PC):**
    - 管理PC (`/etc/wireguard/torii-chan.conf`) の設定を作成済み。
    - サーバー側 (`hosts/torii-chan/services/wireguard.nix`) に管理PCのPeer (`10.0.0.2`) を追加済み。
5.  **SDイメージビルド:** 最新の設定（Peer追加含む）でイメージ (`.img`) を生成済み。

### 次のステップ（デプロイ & 起動）

1.  **SDカード作成:** ビルドしたイメージを物理SDカードに書き込む。
2.  **初回起動 & 鍵配置:**
    - 実機起動後、SSH (`t3u@192.168.0.128`) で接続。
    - `/var/lib/sops-nix/key.txt` を配置（`sudo` パスワード不要）。
3.  **接続確認:** WireGuard (`wg-quick up torii-chan`) を接続し、VPN経由のSSH (`ssh t3u@10.0.0.1` or `192.168.0.128`) を確認。
4.  **HDD移行:** 運用構成 (`.#torii-chan`) への移行作業。

### デプロイコマンド
- SDイメージ作成: `nix build .#nixosConfigurations.torii-chan-sd.config.system.build.sdImage`
- SD書き込み: `sudo dd if=result/sd-image/nixos-image-sd-card-*.img of=/dev/sdX bs=4M status=progress conv=fsync`
- リモート更新 (HDD構成): `nixos-rebuild switch --flake .#torii-chan --target-host t3u@192.168.0.128 --use-remote-sudo`

