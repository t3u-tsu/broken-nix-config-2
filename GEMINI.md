# NixOS設定構築のコンテキスト

## 目的

`.` ディレクトリにて、Orange Pi Zero3 (`torii-chan`) 向けのNixOS設定を構築中。最終目標はSDカードイメージの生成と実機へのデプロイです。

## 現在の状況 (2025-12-29)

**SDイメージ再構築中（Root SSH許可版）。**

### 達成したマイルストーン

1.  **実機セットアップ検証:**
    - 以前のSDイメージで起動、WireGuard接続までは成功することを確認済み。
2.  **デプロイ課題の解決策:**
    - 非特権ユーザー (`t3u`) での初回デプロイ時に署名エラーが発生する問題を回避するため、**初期SDイメージで Root SSH ログインを許可** する方針に変更。
    - `hosts/torii-chan/sd-image-installer.nix` を修正済み。

### 次のステップ（再セットアップ）

1.  **SDイメージ再ビルド:** Rootログイン許可設定を含んだイメージを作成。
2.  **書き込み & 起動:** SDカードに書き込み、実機起動。
3.  **鍵配置:** `t3u` または `root` で入り、`/var/lib/sops-nix/key.txt` を配置。
4.  **デプロイ (SD運用版):**
    - `root` ユーザーとしてデプロイを実行することで、Nixの信頼問題を回避。
    - `nix run ... --target-host root@192.168.0.128`

### デプロイコマンド
- SDイメージ作成: `nix build .#nixosConfigurations.torii-chan-sd.config.system.build.sdImage`
- SD書き込み: `sudo dd if=result/sd-image/nixos-image-sd-card-*.img of=/dev/sdX bs=4M status=progress conv=fsync`
- 初回デプロイ (SD運用): `nix run nixpkgs#nixos-rebuild -- switch --flake .#torii-chan-sd-live --target-host root@192.168.0.128`

