# ホスト名: sando-kun (Core i7 860 サーバー)

このホストは、Core i7 860 を搭載したタワー型サーバーです。

## ハードウェア仕様
- **CPU:** Core i7 860
- **RAM:** 8GB
- **ストレージ:**
  - 250GB HDD (ルート/ブート)
  - 80GB HDD x2 (データ領域)

## 🚀 インストールガイド

NixOS インストーラー環境から、外部マシン経由で以下のコマンドを実行します：

1. **ディスクの初期化とマウント:**
   ```bash
   ssh -t root@<ターゲットIP> "nix --extra-experimental-features 'nix-command flakes' run github:t3u-tsu/nix-config#sando-kun -- \
     --mode destroy,format,mount \
     --flake github:t3u-tsu/nix-config#sando-kun"
   ```
   *注意: デバイス名は実機に合わせて調整が必要な場合があります（デフォルトは /dev/sda, sdb, sdc）。*

2. **SOPS 秘密鍵の配置:**
   ```bash
   ssh root@<ターゲットIP> "mkdir -p /mnt/var/lib/sops-nix"
   cat ~/.config/sops/age/keys.txt | ssh root@<ターゲットIP> "cat > /mnt/var/lib/sops-nix/key.txt"
   ```

3. **NixOS のインストール:**
   ```bash
   ssh root@<ターゲットIP> "nixos-install --flake github:t3u-tsu/nix-config#sando-kun"
   ```

4. **再起動:**
   ```bash
   ssh root@<ターゲットIP> "reboot"
   ```

## 🔐 アクセス
- **管理用IP:** `10.0.0.2` (WireGuard)
- **アプリ用IP:** `10.0.1.2` (WireGuard)
- **SSH アクセス制限:** SSHアクセスは WireGuard (`wg0`) インターフェース経由のみに制限されています。
- **ユーザー:** `t3u` (wheel/sudo 権限あり)
