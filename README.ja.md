# NixOS 構成管理リポジトリ

このリポジトリは、NixOSのマルチホスト構成をFlakesを使用して管理しています。セキュリティ、再現性、およびクロスコンパイル環境を特徴としています。

## ℹ️ ドキュメントの構成

このリポジトリは階層構造になっており、詳細な説明は各所の `README.md` に記載されています。

- `hosts/<ホスト名>/`: 各マシンのハードウェア仕様と固有のデプロイ手順。
- `services/<サービス名>/`: 特定のサービス（Minecraft等）の詳細設定と運用方法。
- `common/`: 全ホストで共通して適用されるパッケージや設定。

## 📂 ディレクトリ構造

```text
.
├── flake.nix           # 構成のエントリポイント
├── hosts/              # ホスト固有の設定
├── common/             # 全ホスト共通の基本設定
├── services/           # 共通サービスの設定
│   ├── minecraft/      # Minecraft ネットワーク (Velocity + Paper)
│   ├── backup/         # Restic による自動バックアップ
│   └── update-hub/     # 調整型自動更新システム (Hub & Client)
├── lib/                # mkSystem などの共通ライブラリ関数
└── secrets/            # 暗号化された秘密情報 (SOPS)
```

## 🖥️ ホスト一覧 (Fleet)

| ホスト名 | 管理IP (WG0) | アプリIP (WG1) | 役割 | ストレージ |
| :--- | :--- | :--- | :--- | :--- |
| `torii-chan` | `10.0.0.1` | `10.0.1.1` | Gateway / Update Hub / DDNS | SD + HDD |
| `sando-kun` | `10.0.0.2` | `10.0.1.2` | Sando Server | SSD |
| `kagutsuchi-sama` | `10.0.0.3` | `10.0.1.3` | Compute Server / Backup Receiver | SSD + 3TB HDD |
| `shosoin-tan` | `10.0.0.4` | `10.0.1.4` | Minecraft / Discord Bridge / Producer | SSD + ZFS Mirror |

## 🛠️ 使用テクノロジー

- **Nix Flakes:** 再現可能なビルドと依存関係管理。
- **sops-nix:** `age` を使用した機密情報の暗号化管理。RCON パスワードやトークンの安全な動的注入を実現。
- **nvfetcher:** 外部バイナリ（プラグイン等）の自動更新管理。
- **WireGuard:** 管理用(wg0)およびアプリ間通信用(wg1)のセキュアなネットワーク。
- **Coordinated Auto Updates:** 毎日午前4時の自動更新システム。Webhook によるプッシュ通知同期を実装。
- **Minecraft Discord Bridge:** 自作の Go 製マルチテナント管理 Bot。Discord からのホワイトリスト管理に対応。
- **Automated Backup (Restic):** 2時間おきの自動バックアップ。マイクラのデータ整合性フック（save-off/on）を完備。
- **ビルド最適化:** aarch64 エミュレーションビルドによるバイナリキャッシュの最大活用。

---

## はじめかた

特定のホストやサービスについて詳しく知るには、それぞれのディレクトリにあるドキュメントを参照してください。
```bash
# 例: マシンの詳細を確認する
cat hosts/torii-chan/README.ja.md
```