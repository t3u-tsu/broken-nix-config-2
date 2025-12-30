# shosoin-tan (タワー型サーバー)

ZFSストレージとNVIDIA Quadroを搭載した汎用サーバー。

## ハードウェア仕様
- **CPU**: Intel Core i7 870
- **GPU**: NVIDIA Quadro K2200
- **ストレージ**:
  - 480GB SSD: ルート領域 (`/`)
  - 1TB HDD x2: ZFSミラー (`tank-1tb`)
  - 320GB HDD x2: ZFSミラー (`tank-320gb`)
  - 2TB HDD: バックアップ用領域 (`ext4`)

## 🔐 アクセス
- **管理用IP:** `10.0.0.4` (WireGuard)
- **SSH アクセス制限:** セキュリティ強化のため、SSHアクセスは WireGuard (`wg0`) インターフェース経由のみに制限されています。

管理用PCからのアクセス：
```bash
ssh t3u@10.0.0.4
```
