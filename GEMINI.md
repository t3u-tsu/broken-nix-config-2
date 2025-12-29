# NixOS設定構築のコンテキスト

## 目的

`.` ディレクトリにて、Orange Pi Zero3 (`torii-chan`) 向けのNixOS設定を構築中。最終目標はSDカードイメージの生成と実機へのデプロイです。

## 現在の状況 (2025-12-29)

**SDイメージのビルドに成功。SOPS鍵を再生成済み。HDD運用に向けた構成準備完了。**

### 達成したマイルストーン

1.  **SDイメージ生成の成功:**
    - `nix build` 正常終了。U-Boot/ATFの問題解決済み。
2.  **SOPS鍵の再生成:**
    - 秘密鍵紛失のため再暗号化実施。
    - **重要:** 実機起動後、`/var/lib/sops-nix/key.txt` に新しい秘密鍵を配置する必要あり。
3.  **HDD運用設定の実装 (`fs-hdd.nix`):**
    - SDカード寿命延命のため、ルートファイルシステムをUSB-HDD (`NIXOS_HDD`) に、`/boot` をSDカード (`NIXOS_SD`) に配置する構成を作成。
    - `flake.nix` のターゲットを分離:
        - `torii-chan-sd`: 初期インストール用SDイメージ (標準インストーラー構成)。
        - `torii-chan`: 実機運用/デプロイ用 (HDDルート構成)。

### リポジトリ構造
- `hosts/torii-chan/fs-hdd.nix`: HDDルート運用のためのファイルシステム定義。
- `README.md`: ビルド・デプロイ手順書（英語）。

## 次のステップ（実機デプロイフロー）

1.  **SDカード作成 & 初回起動:**
    - `nix build .#nixosConfigurations.torii-chan-sd.config.system.build.sdImage`
    - SDカードに焼いて起動。
    - `/var/lib/sops-nix/key.txt` を配置。
2.  **HDD移行作業 (実機上):**
    - USB HDDを接続し、ext4パーティション作成 (Label: `NIXOS_HDD`)。
    - 現在のルートファイルシステム (`/`) をHDDにコピー (`rsync` 等)。
3.  **設定適用 (リモート):**
    - 手元のPCから `nixos-rebuild switch --flake .#torii-chan --target-host ...` を実行。
    - 再起動し、HDDルートでの動作を確認。

## デプロイコマンド
- SDイメージ作成: `nix build .#nixosConfigurations.torii-chan-sd.config.system.build.sdImage`
- リモート更新 (HDD構成): `nixos-rebuild switch --flake .#torii-chan --target-host t3u@192.168.0.128 --use-remote-sudo`

