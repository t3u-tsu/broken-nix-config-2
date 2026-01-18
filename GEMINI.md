# NixOS設定構築 of torii-chan

## 目的

Orange Pi Zero3 (`torii-chan`) 向けのNixOS設定を構築し、SD運用からHDD運用への移行準備を完了する。

## 現在の状況 (2026-01-05)

**shosoin-tan: Minecraft サーバー兼 Coordinated Update Producerとして稼働中。**

**sando-kun: i7-860 タワーサーバー。ZFS Mirror (80GB x2) 構成で稼働開始。**

**torii-chan: SSH 接続安定化（Curve25519強制）、WireGuard MTU 調整 (1300)、および 4GB スワップの常設により運用安定性が大幅に向上。**

**ネットワーク: 全ホストの WireGuard MTU を 1300 に統一。shosoin-tan と kagutsuchi-sama の LAN 切り離しに伴い localNetwork を無効化。**

### 達成したマイルストーン

1.  **WireGuard (wg0)**: 管理用ネットワーク (10.0.0.0/24) を構築。全ホストでSSHをこのインターフェースのみに制限。
2.  **sops-nix**: `key.txt` による復号、および `mutableUsers = false` によるパスワード同期の成功。
3.  **Cloudflare DDNS**: API Token による正常動作を確認。`mc.t3u.uk` および `*.mc.t3u.uk` を追加。
4.  **デプロイ権限**: `trusted-users` 設定完了。
5.  **セキュリティ強化**: `production-security.nix` を適用し、SSHアクセスを WireGuard (wg0) 経由のみに制限。
6.  **shosoin-tan**: Core i7 870 / Quadro K2200 / ZFS Mirror 構成の初期設定を完了。
7.  **torii-chan HDD Boot Fix**: USBストレージ用カーネルモジュール (`uas`, `usb_storage`等) を `initrd` に追加し、`rootdelay` を設定。
8.  **torii-chan HDD移行**: `fs-hdd.nix` を適用し、実データの `rsync` および HDD 起動への移行に成功。
9.  **kagutsuchi-sama Disk ID**: 実機での `lsblk` により `by-id` を特定し、`disko-config.nix` に反映済み。
10. **kagutsuchi-sama Disko**: ライブUSB環境からの SSH リモート Disko 実行に成功。
11. **kagutsuchi-sama OSインストール**: `nixos-install` を実行し、NVIDIAドライバビルドを含む全工程を完了。
12. **kagutsuchi-sama セットアップ完了**: 宣言的パスワード管理の導入と、実機での正常起動・動作を確認。
13. **WireGuard ネットワーク拡張**: `kagutsuchi-sama` (10.0.0.3) および `shosoin-tan` (10.0.0.4) を追加. 管理用PCは `10.0.0.100`。
14. **アプリ間通信用ネットワーク (wg1)**: `10.0.1.0/24` を構築。サーバー間の自由な通信を許可。
15. sando-kun 設定追加: i7 860 / 250GB HDD 構成の初期設定を完了。WireGuard (10.0.0.2 / 10.0.1.2) 設定済み。
16. nitac23s 移行完了: 旧サーバーからのワールドデータ (world, nether, end)、usercache、whitelist の移行および Kagutsuchi-sama での稼働を確認。
17. 基本ツールのモジュール化: 全ホスト共通の基本ツール (`vim`, `git`, `tmux`, `htop`, `rsync` 等) を `common/` に集約し、保守性を向上。
18. Cloudflare DDNS 拡張: `mc.t3u.uk` および `*.mc.t3u.uk` を追加し、Minecraft ネットワーク用のドメイン運用を開始。
19. Velocity 構成の最適化: `forced-hosts` を Nix 式で動的に生成するように変更。`mc.t3u.uk` を `lobby` に、`nitac23s.mc.t3u.uk` を `nitac23s` にマッピング。
20. Lobby サーバーの Void 化: 既存ワールドをリセットし、一切のブロックがない Void ワールドとして再構築。
21. プラグイン自動更新の導入: `nvfetcher` を導入し、ViaVersion/ViaBackwards を常に最新の GitHub リリースから取得してビルドする仕組みを構築。
22. サーバー警告の解消: `LD_LIBRARY_PATH` への `udev` 追加によるライブラリ不足警告の修正、および `paper-global.yml` の `config-version` 指定による警告の解消。
23. 自動更新システムの構築: 毎日午前4時に `nix flake update`、`nvfetcher` 更新、Git コミット＆プッシュ、`nixos-rebuild switch` を自動実行する Systemd Timer を構築.
24. 自動更新モジュールのリファクタリング: `config.users.users` によるパスの動的解決と、未踏環境での自動クローン（セルフヒーリング）機能を実装。
25. Kagutsuchi-sama 障害復旧と接続性改善: 同じ LAN 内での NAT ループバック問題による VPN 不通を解消するため、`/etc/hosts` によるローカル解決を導入。救出用の一時的な LAN SSH 許可を経て、セキュアな元の状態へ復元。
26. ネットワーク設定の共通化: NAT ループバック対策用のローカル DNS 解決を `common/local-network.nix` にモジュール化し、フラグ一つで有効化できるように改善。
27. 自動更新システムの高度化: `pushChanges` フラグを導入し、更新・プッシュ担当（Producer）と適用担当（Consumer）を分離。また、`nvfetcher` タスクをサービス側から動的に登録する構成にリファクタリングし、ホスト間の移動や拡張性を向上。
28. Nix設定の共通化と集約: `common/nix.nix` を新設し、実験的機能、バイナリキャッシュ、`trusted-users` 設定を一括管理. 各ホストからの重複設定を排除。
29. aarch64ビルドの最適化: `torii-chan` のビルドをクロスコンパイルからエミュレーションベースのネイティブビルドに移行。`binfmt` と `extra-platforms` 設定により、x86_64ホスト上で公式のaarch64バイナリキャッシュを利用可能にした。
30. Coordinated Update System の確立: `services/update-hub` を新設し、Hub サーバーと各ホスト用の更新ロジックを集約。ファイアウォール設定（wg0/wg1）を最適化して外部・内部からのステータス確認を可能にした。
31. shosoin-tan Disk ID特定: 実機での `lsblk` により 5 台のディスク ID を特定し、`disko-config.nix` に反映。
32. Legacy BIOS (GRUB) 対応: i7-870 環境での UEFI 非対応を解決するため、BIOS boot パーティション (EF02) の追加と Legacy GRUB 設定への移行を実施。
33. リモートビルド・インストール確立: ターゲット機（shosoin-tan）の負荷軽減のため、ビルドホストで `nixos-system` を構築し `nix copy` で転送してから `nixos-install --system` を実行する高安定性インストール手順を確立。
34. shosoin-tan セットアップ完了: CPU オーバークロック解除による安定化を経て、NixOS のインストールと WireGuard 接続に成功。
35. shosoin-tan ネットワーク安定化: USB-LAN アダプタ環境での不安定さを解消するため、WireGuard MTU を 1380 に設定し、`localNetwork` モジュールによるエンドポイントのローカル解決を導入して起動時の接続を確実に安定させた。
36. タイムゾーンのJST統一: 全ホスト共通設定として `common/time.nix` を導入し、タイムゾーンを `Asia/Tokyo` (JST) に統一。あわせて `chrony` を有効化し、時刻同期の精度 and 安定性を向上させた。
37. Minecraft サーバー移行: マイクラ関連サービス一式 (Velocity, Lobby, nitac23s) を `kagutsuchi-sama` から `shosoin-tan` へ移行。データの `rsync` 同期、`torii-chan` のポート転送先変更 (10.0.1.4)、および自動更新 Producer 権限の移譲を完了。
38. Velocity 警告の解消: `config-version` を `2.7` に更新し、非推奨の `forwarding-secret-file` パラメータを削除することで、セキュリティ警告および設定バージョン警告を修正。
39. バックアップシステムの構築と共通化: `services/backup` を新設し、`restic` による 2重バックアップ（ローカル ZFS & リモート Kagutsuchi）をモジュール化。SSH 設定の共通化により、安全で保守性の高いバックアップ運用を実現。
40. Minecraft Discord Bridge の導入: Go 製のマルチテナント型管理 Bot を開発・公開。Discord からのホワイトリスト管理機能、Unix ドメインソケットによるローカル管理を実現。
41. セキュリティ強化と構成の洗練: マイクラの RCON パスワードを `sops-nix` 管理に移行。モジュールによる自動上書きを回避しつつ、起動時に機密情報を安全に注入する独自の `server.properties` 生成ロジックを確立。
42. 自動更新システムのプッシュ化: Webhook 通知機能を Hub に実装し、Producer の更新直後に全ホストが即座に同期を開始するリアルタイム更新を実現。
43. ホワイトリスト管理の確実化: マイクラ側の不規則な挙動を回避するため、`bridge.db` だけでなく `whitelist.json` も直接編集・リロードする方式を採用し、BE/Java 共に 100% 確実な削除を実現。合わせて `bridge.db` もバックアップ対象に追加。
44. torii-chan SSH/MTU 安定化: 低リソース環境での接続タイムアウト回避のため `KexAlgorithms` を Curve25519 に固定。また楽天モバイル環境（MTU 1340）への対応として WireGuard MTU を 1300 に調整。
45. torii-chan スワップ常設化: メモリ不足によるビルド失敗 (OOM) を防ぐため、4GB のスワップファイルを常設。`vm.swappiness = 10` によるストレージ寿命への配慮も実施。
46. 自動更新システムの堅牢化: Hub から取得するコミットハッシュのクリーンアップ処理を追加し、不可視文字による `git reset` 失敗を解消。あわせて `git fetch` の確実に実行するよう修正。
47. sando-kun 実機インストール: shosoin-tan で確立したリモートビルド手順を用いて、sando-kun の構築を完了。Legacy BIOS 環境での安定稼働を確認。
48. WireGuard ピア自動リトライの導入: 起動時の名前解決失敗に対処するため、Systemd の `Restart=on-failure` を全ホストの WireGuard ピア設定に自動適用する共通モジュールを実装。
49. タワー型サーバー設定の共通化: `shosoin-tan`, `kagutsuchi-sama`, `sando-kun` で重複していた設定を `common/tower-server/` に集約し、保守性と可読性を大幅に向上。
50. 自動更新システムのリファクタリング: Nix ファイル内に埋め込まれていた長い Python/Bash スクリプトを外部ファイル化し、シンタックスハイライトと PEP8 準拠の管理を可能にした。
51. Discord Bridge RCON の堅牢化: RCON プロトコル処理の修正とログ拡充を行い、バイナリログの発生を抑制。また、`sops.templates` を用いて環境変数を安全に注入する仕組みを構築。
52. 自動更新システムの再設計 (Dynamic Discovery): Hub 側の静的 IP マップを廃止し、報告に基づいた動的な IP 登録（Dynamic Discovery）を実装。合わせて Hub 自身への通知をローカルコマンド実行に置き換え、ネットワーク起因のタイムアウトを解消。
53. 自動更新クライアントの強化: `git fetch origin main` による確実なオブジェクト取得と、`--no-reexec` フラグによる D-Bus 切断対策を導入し、大規模更新時の安定性を向上。

### 運用・デプロイ上の知見 (Operational Notes)

- **WireGuard のリトライ**: 名前解決に失敗しても 5 秒おきに自動リトライされるため、起動直後の VPN 不通は自動的に解消されます。
- **設定の共通化**: 新しいタワー型サーバーを追加する際は、`../../common/tower-server` を import するだけで標準的なセキュリティとユーザー環境が整います。
- **自動更新の監視**: `torii-chan` (10.0.0.1:8080/status) で全ホストの同期状況をリアルタイムに確認可能です。
- **自動更新のデバッグ**: 各ホストの `/var/lib/update-hub/hub.log` (Hub) や `journalctl -u nixos-auto-update` (Client) で詳細な同期プロセスを確認できます。
- **Minecraft コンソールへの接続**: 各サービスは `tmux` セッションで動作。
  - 接続: `sudo tmux -S /run/minecraft/<サービス名>.sock attach`
  - 離脱: `Ctrl+B` -> `D`
- **Discord Bridge の操作**:
  - ローカル操作: `echo 'status' | sudo nc -U -N /run/minecraft-discord-bridge/bridge.sock` (※tmux ではなく nc を使用)
  - 招待トークン発行: `echo 'invite-create nitac23s' | sudo nc -U -N /run/minecraft-discord-bridge/bridge.sock`
- **マイクラ設定の注意**: `server.properties` は Nix モジュールと競合するため、`nitac23s.nix` 内の `preStart` で動的に生成・上書きしています。パスワード等を変更する場合は、Nix 側の設定を更新してください。
- **非NixOS環境からのデプロイ**: `nixos-rebuild` がない場合、`nix run` 経由で実行。
  - 例: `nix run nixpkgs#nixos-rebuild -- switch --flake .#<ホスト> --target-host <ユーザー>@<IP> --sudo --ask-sudo-password`
- **Flake への反映**: Nix Flake は Git 管理下のファイルのみを認識するため、新規作成・変更したファイルは必ず `git add` すること。
- **リソース制限ホストのデプロイ**: `torii-chan` 等の低リソース機へのデプロイ時は、ネットワーク瞬断や SSH タイムアウトに注意。安定しない場合はリモート側で `nixos-rebuild` を実行する。

### 次のステップ

1.  **バックアップの整合性確認**: 初回バックアップ完了後、`restic check` を実行し、データの整合性と Kagutsuchi-sama 側のディスク使用量を確認する。
2.  **共通設定の拡充**: シェルの設定 (zsh/fish) や alias など、全ホストで共通化したい設定を `common/` に追加していく。
3.  **自動更新ログの通知**: 更新失敗時に Discord 等へ通知する仕組みの検討。

### 運用ルール (開発ワークフロー)

- **言語設定**: ユーザーとの対話、説明、進捗報告などのメッセージは**すべて日本語**で行うこと。
- **文書管理**: トップレベルの `README` を整理する際は、ホスト一覧や全体構造などの「プロジェクト俯瞰に必要な共通概要事項」を削除しないこと。詳細はサブディレクトリの `README` に任せつつ、全体像はトップレベルで維持し、各所への誘導を行う。
- 変更後は必ず `nix flake check` を実行し、構文エラーがないか確認する。
- ホスト追加や重要な変更の際は、`GEMINI.md` および `README.md` (日/英) を更新する。
- 変更はこまめに git commit する。

### 主要コマンド

- torii-chan デプロイ: `nixos-rebuild switch --flake .#torii-chan --target-host t3u@10.0.0.1 --sudo`
- kagutsuchi-sama デプロイ: `nixos-rebuild switch --flake .#kagutsuchi-sama --target-host t3u@10.0.0.3 --sudo`
- shosoin-tan デプロイ: `nixos-rebuild switch --flake .#shosoin-tan --target-host t3u@10.0.0.4 --sudo`
- sando-kun デプロイ: `nixos-rebuild switch --flake .#sando-kun --target-host t3u@10.0.0.2 --sudo`
- 秘密情報の編集: `nix shell nixpkgs#sops -c sops secrets/secrets.yaml`
- 外部からのデプロイ (nix run 経由): `nix run nixpkgs#nixos-rebuild -- switch --flake .#<host> --target-host t3u@<IP> --sudo --ask-sudo-password`