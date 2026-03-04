# NixOS設定構築

### 運用ルール
- ユーザーとの対話、説明、進捗報告などのメッセージは**すべて日本語**で行うこと。
- 開発ワークフローについては`開発ワークフロー`セクションの手順を**絶対遵守**すること。

### 構成マインドセット
- **`modules/`**: 再利用可能な「仕組み」の置き場。
  - `core/`: 基盤設定（Nix, Network, etc.）
  - `packages/`: 機能別パッケージパック
  - `shell/`: Zsh & Home-manager による環境統合
  - `services/`: 各種サーバーサービス
  - `profiles/`: 役割ごとのプリセット
- **`hosts/`**: マシンごとの「実体」定義。`modules/` から必要なものを組み合わせて構成する。

### 開発ワークフロー
  0. 作業の開始前に、関連する全ての`README.md`を読み、内容を把握してから作業を開始すること。
  1. Nix Flake は Git 管理下のファイルのみを認識するため、新規作成・変更したファイルは必ず `git add .` すること。
  2. `nix flake check` を実行し、構文エラーがないか確認する。
  3. 変更を `git commit` する。
  4. `git push` する。
  5. 各ホストへの反映は自動または Hub 通知経由で行う。

### 主要コマンド
- torii-chan デプロイ: `nixos-rebuild switch --flake .#torii-chan --target-host t3u@10.0.0.1 --sudo`
- Hubへの通知 (一斉更新): `curl -X POST -H "Content-Type: application/json" -d "{\"commit\": \"$(git rev-parse HEAD)\", \"host\": \"$(hostname)\"}" http://10.0.0.1:8080/producer/done`
- 秘密情報の編集: `nix shell nixpkgs#sops -c sops secrets/secrets.yaml`

### 運用・デプロイ上の知見
- **Zsh & Home-manager**: 全ホストで `zsh` がデフォルト。エイリアス（ls=eza, cat=bat等）は Home-manager で一括管理。
- **ハードウェアツール**: `my.hardware.pc-tools.enable = true;` を設定したホストでのみ、物理サーバー用ツールがインストールされる。
- **パッケージ制御**: `my.packages.<category>.enable = false;` で不要なツール群を除外可能（低リソース機向け）。
- **マイクラコンソール**: `sudo tmux -S /run/minecraft/<サービス名>.sock attach`

### 作業記録 (Activity Log)
- **2026-03-05**: リポジトリ構成の大規模再編。
    - `common/` および `services/` を `modules/` 配下へ統合。
    - パッケージ管理のオプトイン/オプトアウト化、ハードウェア特性フラグの導入。
    - 全ホストのデフォルトシェルを Zsh へ移行し、Home-manager でシェル環境を高度に統合。
