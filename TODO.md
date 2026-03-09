# リポジトリ改善 TODO リスト

このリストは、NixOS 設定リポジトリのさらなる保守性・拡張性向上のための提案を優先度別にまとめたものです。

---

### **完了済みタスク**
- [x] **Sops 共通設定の整理**: `modules/core/sops.nix` への集約。
- [x] **リポジトリ所有権の強制**: `update-hub` での `chown` 実施。
- [x] **コマンドの即時実行環境 (nix-index / comma) の構築**: 全ホストへの導入完了。
- [x] **Shell UI の刷新 (Starship)**: 全ホストへの導入とコンパクト化。
- [x] **Home-manager 設定の構造化**: `modules/home/` 配下への機能別分割。
- [x] **デスクトップ構成の高度な構造化**: カテゴリー別オプション化と `dev-tools` のディレクトリ化。
- [x] **Zen Browser の宣言的カスタマイズ**: 拡張機能、コンテナ、検索エンジンの自動構成。

---

### **進行中・今後のタスク**

- [ ] **Niri デスクトップ環境への移行 (Scrollable-Tiling Wayland)**:
  - [ ] **基盤構築 (NixOS)**:
    - `modules/services/desktop/niri.nix`: コンポジター本体とポータル設定。
    - `modules/services/desktop/greetd.nix`: `tuigreet` による TUI ログイン画面の構築。
    - `modules/services/desktop/pipewire.nix`: PipeWire によるオーディオ・録画基盤の確立。
  - [ ] **ユーザー環境の構築 (Home Manager - modules/home/desktop/niri/)**:
    - `default.nix`: Niri 本体設定・キーバインド・ワークスペース管理。
    - `shell.nix`: `noctalia-shell` 統合。
    - `addons.nix`: `fuzzel`, `swaync`, `wlogout`, `swayosd` 等。
    - `wallpaper.nix`: `awww` によるアニメーション壁紙の設定。
    - `power.nix`: `hyprlock`, `hypridle` による電源管理。
  - [ ] **システム全体のテーマ統一 (Dracula Theme)**:
    - Alacritty, Fuzzel, Waybar, Starship, GTK/Qt すべてを Dracula テーマで統一する。
  - [ ] **周辺ツールの統合**:
    - `nautilus` (ファイルマネージャ) への移行。
    - `cliphist` + `wl-clipboard` によるクリップボード履歴。
    - `nm-applet`, `blueman-applet` によるネットワーク・BT管理。
    - `grim`, `slurp`, `playerctl` 等の利便性向上ツールの設定。
  - [ ] **クリエイティブ強化**: `modules/home/desktop/creative.nix` への `OBS Studio` 追加。

- [ ] **SOPS 機密情報の構造化と権限分離**:
  - 現在 `secrets/secrets.yaml` に集中している機密情報を、ホスト別・サービス別に分割し、各ホストの復号権限を最小化する。
- [ ] **NVIDIA ドライバ設定の抽象化**:
  - `shosoin-tan`, `kagutsuchi-sama`, `BrokenPC` で重複している設定を `modules/hardware/nvidia.nix` 等に抽出し、構成をオプション化する。
- [ ] **低リソース機向けの分散ビルド (Remote Build) 導入**:
  - `torii-chan` 等でのビルド負荷を軽減するため、他の強力なマシンをビルドホストとして利用する設定を構築する。
- [ ] **WireGuard 構成のモジュール化**:
  - ホスト間で重複しているピア定義を中央管理し、自動生成・同期できる仕組みを作る。
- [ ] **ZFS 設定の共通化**:
  - 共通設定を `modules/core/zfs.nix` にまとめ、各ホストの設定を簡略化する。
- [ ] **Update Hub のセキュリティ強化**:
  - サービスの実行ユーザーを非 root に変更し、権限を制限する。
- [ ] **CI/CD の構築**:
  - GitHub Actions 等で `nix flake check` を自動実行し、品質を担保する。
- [ ] **デスクトップ・ゲーミング最適化**:
  - Steam, MangoHud 以外のパフォーマンスチューニング（GameMode 等）の追加。
- [ ] **システムパッケージ層の整理**:
  - `modules/packages/` の構成をさらに見直し、ベースシステムとユーザー環境の境界を洗練させる。
