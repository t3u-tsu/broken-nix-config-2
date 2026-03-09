# システムパッケージ

オプションを通じて有効/無効を制御できる、システムレベルのパッケージグループの定義です。

## 📂 カテゴリー

- **`base.nix`**: 基本的なシステム管理に必要な最小限のツール（git, vim 等）。
- **`monitoring.nix`**: システムモニタリングツール（btop, fastfetch 等）とハードウェア固有ツール。
- **`network-tools.nix`**: ネットワーク診断・ユーティリティツール（curl, nmap, gping 等）。
- **`data.nix`**: データ処理と圧縮・展開ツール（jq, unzip 等）。
- **`nix-tools.nix`**: Nix 固有の開発および管理ツール。
- **`security.nix`**: セキュリティ関連ツールとハードニング設定。
- **`default.nix`**: すべての `my.packages.*` オプションの定義。
