# 作業ログ: SOPS 最小権限パーミッション移行の完了と検証 (2026-06-01)

## 課題
- 途中まで進んでいた `refactor/sops-permissions` ブランチの作業を再開し、完遂する必要があった。
- 既存の `secrets/secrets.yaml` のデータが新設計の `secrets/hosts/` および `secrets/services/` へまだ分割・移行されていなかった。
- `.sops.yaml` に記述されているマスターキーや各ホストキーがプレースホルダーのままになっていた。
- リビルド時に `home-manager` 側で復号用の鍵ソースが未定義であることによるアサーションエラーが発生した。
- `nixpkgs` アップデートによる `fast-cli` パッケージ廃止に伴うビルドエラーが発生した。
- **秘密鍵の一括管理リスク（追加修正）**: 当初は WireGuard の秘密鍵を `secrets/services/wireguard.yaml` に一括格納していたが、これではホストの1台が突破された際に全ホストの WireGuard 鍵が漏洩する脆弱性があったため、厳格な最小権限モデルへと分散設計を改善する必要があった。
- **宣言的 age 秘密鍵生成時のデッドロック**: Home Manager にて `sops.age.keyFile` を指定したが、ファイルがまだ存在しない段階で `sops-nix` が復号（`setupSecrets`）を試みるため、サービス起動が失敗してロールバックするデッドロックが発生していた。

## 実施内容

### 1. 最新の main ブランチの変更を取り込み
- 最新の `main`（Ghostty 移行など）を `refactor/sops-permissions` に安全にマージ。

### 2. ホストおよびマスターの age 公開鍵の取得・生成
- **BrokenPC（ローカル機）**: SSHホストキー（`/etc/ssh/ssh_host_ed25519_key`）を手動で安全に生成し、`ssh-to-age` で age 公開鍵を取得。
- **リモートホスト**: `known_hosts` にあった `torii-chan`, `sando-kun`, `shosoin-tan`, `kagutsuchi-sama` の SSHホスト公開鍵をすべて `ssh-to-age` で age 公開鍵に変換。
- **マスターキー**: `age-keygen` を用いて、オフラインマスターキーを新規生成。ユーザー自身による完全プライベートなローテーションにより、最終的な新マスターキーが安全に適用された。
- **`.sops.yaml` の更新**: プレースホルダーを上記で得られた実際の公開鍵にすべて置換。

### 3. 秘密情報の完全移行（個別暗号化・最小権限の完全確立）
- 既存の平文秘密情報を、新設計のディレクトリ構造に分割して個別に暗号化。
  - **ホスト固有 (`secrets/hosts/`)**: `torii-chan.yaml`, `shosoin-tan.yaml`, `kagutsuchi-sama.yaml`, `sando-kun.yaml`, `BrokenPC.yaml`
  - **サービス固有 (`secrets/services/`)**: `minecraft.yaml`, `backup.yaml`, `signing.yaml`, `ddns.yaml`
  - **共通設定 (`secrets/common.yaml`)**: （空のプレースホルダー）
- **WireGuard 鍵の完全分離**: 当初 `services/wireguard.yaml` にまとめられていた全ホストの WireGuard 秘密鍵を、セキュリティ境界を完全に分離するため、それぞれのホスト固有ファイル（`secrets/hosts/*.yaml`）へと移行し、 `services/wireguard.yaml` を削除。
- 古い `secrets/secrets.yaml` は Git から安全に削除。

### 4. 暗号ファイル参照の定義修正とシンプル化
- `shosoin-tan` の `backup.nix` / `discord-bridge.nix`、`torii-chan` の `ddns.nix` 等において、分割先のサービス固有 yaml ファイルを明示的に指すように `sopsFile` オプション（`../../../secrets/services/xxx.yaml`）を追加。
- 各ホストの `wireguard.nix` については、鍵がそれぞれのホスト固有 secrets ファイルに格納されたため、明示的な `sopsFile` オプションを削除し、システムデフォルトの自動ホスト参照に回帰させることで設定コードを大幅にシンプル化。

### 5. パッケージ競合の解決と Home Manager 設定の修正
- nixpkgs アップデートで廃止された `fast-cli` パッケージをシステムパッケージリストからクリーンアップ。
- Home Manager 側（`modules/home/default.nix`）で `Failed assertions` が発生していたため、 `sops.age.sshKeyPaths` に `/home/t3u/.ssh/id_ed25519` を指定し、ユーザー環境での秘密情報の正常な復号ルートを確立。

### 6. 日常用 age 秘密鍵（keys.txt）の宣言的生成アクティベーションの実装
- Home Manager の `modules/home/default.nix` にて、アクティベーションスクリプト `home.activation.generateAgeKey` を定義。
- `lib.dag.entryBetween [ "writeBoundary" ] [ "setupSecrets" ]` を指定し、`sops-nix` が秘密情報を復号しようとする直前に、ユーザーの日常用 SSH 鍵（`~/.ssh/id_ed25519`）から age 秘密鍵（`~/.config/sops/age/keys.txt`）を自動的かつ安全に生成・配置するフローを実装。これにより、初期デプロイ時のデッドロックを完全に解決した。

## 検証と適用
1. `nix flake check` を実行し、全ホスト設定で構文と依存関係の検証をパス。
2. `sudo nixos-rebuild dry-activate --flake .#BrokenPC` で secrets の正常な復号とアクティベーションを確認。
3. `sudo nixos-rebuild switch --flake .#BrokenPC` を実行し、実機への適用を完全にパス。
4. **日常用 secrets 復号テスト（実機確認）**:
   - 日常ユーザー `t3u` で `sops -d secrets/services/signing.yaml` を実行し、GPG署名鍵が正常に復号されることを確認。
   - 日常ユーザー `t3u` で `sops -d secrets/hosts/BrokenPC.yaml` を実行し、権限不足で期待通りに失敗（FAILED）することを確認。
   - `sudo` 権限（ホスト鍵）を用いて `BrokenPC.yaml` が正常に復号できることを確認。
   これにより、日常用と管理者用のセキュリティ境界の完全隔離が実機で証明された。

## 次のステップ
- **新マスターキーの保存**: ご自身でローテーションされた新しい秘密鍵を、安全なパスワードマネージャ等にオフラインで大切に保存してください。
- **ブランチのプッシュとPR**: `refactor/sops-permissions` ブランチをリモートにプッシュし、動作検証済みとして `main` へプルリクエストを作成します。
