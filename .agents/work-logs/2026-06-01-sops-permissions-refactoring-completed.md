# 作業ログ: SOPS 最小権限パーミッション移行の完了と検証 (2026-06-01)

## 課題
- 途中まで進んでいた `refactor/sops-permissions` ブランチの作業を再開し、完遂する必要があった。
- 既存の `secrets/secrets.yaml` のデータが新設計の `secrets/hosts/` および `secrets/services/` へまだ分割・移行されていなかった。
- `.sops.yaml` に記述されているマスターキーや各ホストキーがプレースホルダーのままになっていた。
- リビルド時に `home-manager` 側で復号用の鍵ソースが未定義であることによるアサーションエラーが発生した。
- `nixpkgs` アップデートによる `fast-cli` パッケージ廃止に伴うビルドエラーが発生した。

## 実施内容

### 1. 最新の main ブランチの変更を取り込み
- 最新の `main`（Ghostty 移行など）を `refactor/sops-permissions` に安全にマージ。

### 2. ホストおよびマスターの age 公開鍵の取得・生成
- **BrokenPC（ローカル機）**: SSHホストキー（`/etc/ssh/ssh_host_ed25519_key`）を手動で安全に生成し、`ssh-to-age` で age 公開鍵（`age1l5tjtsw70k40pzl2ndzay89zr8e475vpc2kymrpy7p67p42pggns5y2mkk`）を取得。
- **リモートホスト**: `known_hosts` にあった `torii-chan`, `sando-kun`, `shosoin-tan`, `kagutsuchi-sama` の SSHホスト公開鍵をすべて `ssh-to-age` で age 公開鍵に変換。
- **マスターキー**: `age-keygen` を用いて、オフラインマスターキーを新規生成。
  - 公開鍵: `age1r93dvhlat70mc292gnfy8zswnq4a99hk0q3zmc9rm5n9p4jcjy0s4aclwl`
- **`.sops.yaml` の更新**: プレースホルダーを上記で得られた実際の公開鍵にすべて置換。

### 3. 秘密情報の完全移行（個別暗号化）
- 既存の平文秘密情報を、新設計のディレクトリ構造に分割して個別に暗号化。
  - **ホスト固有 (`secrets/hosts/`)**: `torii-chan.yaml`, `shosoin-tan.yaml`, `kagutsuchi-sama.yaml`, `sando-kun.yaml`, `BrokenPC.yaml`
  - **サービス固有 (`secrets/services/`)**: `wireguard.yaml`, `minecraft.yaml`, `backup.yaml`, `signing.yaml`, `ddns.yaml`
  - **共通設定 (`secrets/common.yaml`)**: （空のプレースホルダー）
- 古い `secrets/secrets.yaml` は Git から安全に削除。

### 4. 暗号ファイル参照の定義修正 (`sopsFile` の追加)
- 各ホスト固有の `wireguard.nix`、および `shosoin-tan` の `backup.nix` / `discord-bridge.nix`、`torii-chan` の `ddns.nix` 等において、分割先のサービス固有 yaml ファイルを明示的に指すように `sopsFile` オプション（階層深さを正確に考慮した `../../../secrets/services/xxx.yaml`）を追加。

### 5. パッケージ競合の解決と Home Manager 設定の修正
- nixpkgs アップデートで廃止された `fast-cli` パッケージをシステムパッケージリストからクリーンアップ。
- Home Manager 側（`modules/home/default.nix`）で `Failed assertions` が発生していたため、 `sops.age.sshKeyPaths` に `/home/t3u/.ssh/id_ed25519` を指定し、ユーザー環境での秘密情報の正常な復号ルートを確立。

## 検証と適用
1. `nix flake check` を実行し、全ホスト設定（`torii-chan`, `shosoin-tan`, `kagutsuchi-sama`, `sando-kun`, `BrokenPC`）で構文と依存関係の検証をパス。
2. `sudo nixos-rebuild dry-activate --flake .#BrokenPC` で secrets の正常な復号とアクティベーションを確認。
3. `sudo nixos-rebuild switch --flake .#BrokenPC` を実行し、実機への適用を完全にパス。

## 次のステップ
- **マスターキーの保存**: 今回生成されたマスターキーの秘密鍵（`AGE-SECRET-KEY-1D37F2RUUKRX4TTV2L5EDE73G6JUHVHXWKSE4AGGYWY8P82YTAG6QWLH6TF`）を、安全なパスワードマネージャ等にオフラインで大切に保存してください。
- **ブランチのプッシュとPR**: `refactor/sops-permissions` ブランチをリモートにプッシュし、動作検証済みとして `main` へプルリクエストを作成します。
