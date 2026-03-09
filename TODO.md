# リポジトリ改善 TODO リスト

このリストは、NixOS 設定リポジトリのさらなる保守性・拡張性向上のための提案を優先度別にまとめたものです。

---

- [ ] **NVIDIA ドライバ設定の抽象化**:
  - `shosoin-tan`, `kagutsuchi-sama`, `BrokenPC` で重複・混在している NVIDIA ドライバの設定を `modules/hardware/nvidia.nix` 等に抽出し、ハイブリッド構成や安定版・最新版の切り替えをオプションで管理できるようにする。
- [ ] **ZFS 設定の共通化**:
  - `boot.supportedFilesystems = [ "zfs" ]` などの共通設定を `modules/core/zfs.nix` にまとめ、各ホストからはプール名のみの指定で済むようにする。
- [x] **Sops 共通設定の整理**: (完了: `modules/core/sops.nix` への集約済み)
- [ ] **Update Hub の権限管理**:
  - `update-hub` サービスの実行ユーザーを `root` から専用の低権限ユーザーに変更し、セキュリティを強化する。
- [x] **リポジトリ所有権の強制**: (完了: `update-hub` の `postStart` で `chown` を実施)
- [ ] **CI での構文チェック自動化**:
  - GitHub Actions 等を利用して、プッシュ時に `nix flake check` を自動実行する仕組みを構築する。
- [ ] **開発環境の Flake 統合**:
  - `devShells` を活用し、各リポジトリのビルドに必要なツールを `nix develop` で即座に呼び出せるようにする。
- [ ] **WireGuard 構成のモジュール化**:
  - 現在各ホストの `services/wireguard.nix` に散らばっている設定を、共通のインターフェース・ピア定義を生成するマクロ的なモジュールに整理する。
- [ ] **低リソース機向けの分散ビルド (Remote Build) 導入**:
  - `torii-chan` (RAM 1GB) 等の低リソース環境でのビルド負荷を軽減するため、`shosoin-tan` や `BrokenPC` をビルドホストとして利用する分散ビルド設定を `modules/core/nix.nix` に構築する。
- [ ] **SOPS 機密情報の構造化と権限分離**:
  - 現在 `secrets/secrets.yaml` に集中している機密情報を、ホスト別・サービス別に分割。`.sops.yaml` の `creation_rules` を見直し、各ホストが必要最小限の鍵のみを復号できる「権限分離」を実現する。
- [ ] **Shell UI の視認性向上 (Starship)**:
  - Zsh プロンプトを Starship に移行。Git ステータスやプロジェクト情報を美しく表示し、`modules/home/default.nix` で一括管理する。
- [ ] **コマンドの即時実行環境 (nix-index / comma) の構築**:
  - 未インストールのコマンドを `, <cmd>` で即座に実行できる環境を構築。`nix-index` を定期実行し、`nix shell` を自動化する comma (`,`) を導入する。
- [ ] **デスクトップ・ゲーミング最適化**:
  - MangoHud (FPS表示) や Steam の有効化、パフォーマンス向上のためのカーネルチューニングを `modules/profiles/desktop` に追加する。