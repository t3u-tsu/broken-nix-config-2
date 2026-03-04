# リポジトリ改善 TODO リスト

このリストは、NixOS 設定リポジトリのさらなる保守性・拡張性向上のための提案を優先度別にまとめたものです。

---

## 🔝 最優先 (保守性の向上)

- [ ] **NVIDIA ドライバ設定の抽象化**:
  - `shosoin-tan` と `kagutsuchi-sama` で重複している NVIDIA ドライバの設定 (`hardware.nvidia`, `services.xserver.videoDrivers`) を `modules/hardware/nvidia.nix` 等に抽出し、オプションで管理できるようにする。
- [ ] **ZFS 設定の共通化**:
  - `boot.supportedFilesystems = [ "zfs" ]` や `boot.zfs.forceImportRoot = false` などの共通設定を `modules/core/zfs.nix` にまとめ、各ホストからはプール名のみの指定で済むようにする。
- [ ] **Sops 共通設定の整理**:
  - `torii-chan` 等に記述されている `sops.age.keyFile` などの基本設定を `modules/core/sops.nix` に集約し、各ホストでの記述を最小限にする。

## ⏩ 優先 (機能強化)

- [ ] **プロフィール (Profiles) のさらなる活用**:
  - `tower-server` 以外のプロフィール（例：`minimal-server`, `dev-workstation`）を作成し、多種多様なホスト展開に備える。
- [ ] **ハードウェア特性に基づく自動最適化**:
  - CPU の世代（Core i7 870 等）に応じたマイクロコードの適用や、ディスク種類による I/O スケジューラの最適化などを自動化する仕組みの検討。
- [ ] **Update Hub の権限管理**:
  - `update-hub` サービスの実行ユーザーを `root` から専用の低権限ユーザーに変更し、セキュリティを強化する。

## 🟢 長期的 (品質・体験の向上)

- [ ] **CI での構文チェック自動化**:
  - GitHub Actions 等を利用して、プッシュ時に `nix flake check` を自動実行する仕組みを構築する。
- [ ] **カスタマイズ可能な Zsh テーマの導入**:
  - `oh-my-zsh` 以外の軽量なプラグインマネージャ（例：`zinit`, `antidote`）の検討や、Starship プロンプトの導入による視認性向上。
- [ ] **開発環境の Flake 統合**:
  - `devShells` を活用し、各リポジトリのビルドに必要なツールを `nix develop` で即座に呼び出せるようにする。
