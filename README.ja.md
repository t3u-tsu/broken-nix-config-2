# NixOS 構成管理リポジトリ

このリポジトリは、NixOSのマルチホスト構成を Flakes と **Modular Architecture** を用いて管理しています。

## 📂 ディレクトリ構造

リポジトリは「仕組み（Modules）」と「実体（Hosts）」に分かれています。

```text
.
├── flake.nix           # 構成のエントリポイント
├── hosts/              # ホスト固有の設定 (torii-chan, shosoin-tan, etc.)
└── modules/            # 再利用可能なモジュール集
    ├── core/           # 基盤設定 (Nix, Network, WireGuard)
    ├── packages/       # 機能別パッケージ群 (my.packages.*)
    ├── shell/          # Zsh & Home-manager による環境統合
    ├── services/       # サーバーサービス (Minecraft, Backup, etc.)
    └── profiles/       # 役割ごとのプリセット (Tower Server, etc.)
```

## 🚀 デプロイと反映

通常、変更は GitHub へ Push することで **Update Hub** を介して全ホストに自動反映されます。

### 全ホストへの即時反映
GitHub へ Push した後、Hub (`torii-chan`) へ通知することで、全ホストの更新を即座にトリガーできます。
```bash
curl -X POST -H "Content-Type: application/json" -d "{\"commit\": \"$(git rev-parse HEAD)\", \"host\": \"$(hostname)\"}" http://10.0.0.1:8080/producer/done
```

## 🛠️ 主な機能

- **Zsh & Home-manager**: 全ホストで Zsh がデフォルト。エイリアスや補完が高度に統合。
- **Modular Packages**: `my.packages.monitoring.enable = false` のように機能別に制御可能。
- **Smart Hardware Tools**: `my.hardware.pc-tools.enable = true` で物理サーバー用ツールをオプトイン。
- **sops-nix**: `age` を用いた機密情報の暗号化。
- **Automated Backup**: Restic による 2 時間おきの自動バックアップ。

詳細は [GEMINI.md](GEMINI.md) または各モジュールの `README.md` を参照してください。