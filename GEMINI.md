# NixOS設定構築

### 運用ルール
- ユーザーとの対話、説明、進捗報告などのメッセージは**すべて日本語**で行うこと。
- 開発ワークフローについては`開発ワークフロー`セクションの手順を**絶対遵守**すること。

### 開発ワークフロー
  0. 作業の開始前に、関連する**全ての`README.md`を読み**、内容を把握してから作業を開始すること。
  1. Nix Flake は Git 管理下のファイルのみを認識するため、新規作成・変更したファイルは必ず `git add .` すること。Git 管理下に起きたくないファイルは `.gitignore` に追加すること。
  2. `nix flake check` を実行し、構文エラーがないか確認する。
  3. 変更を `git commit` する。コミットメッセージの記法は `git log` を参照すること。
  4. `git push` する。
  5. `nixos-rebuild switch --flake .#<ホスト> --target-host <ユーザー>@<IP> --sudo` を実行する。
  6. 作業が終了したら変更内容に基づき `GEMINI.md` および `README.md` (日/英) を更新する。
      - `README.md` (英語) と `README.ja.md` (日本語) は**内容を常に同期させる**こと。
      - トップレベルの `README` を整理する際は、ホスト一覧や全体構造などの「プロジェクト俯瞰に必要な共通概要事項」を削除しないこと。詳細はサブディレクトリの `README` に任せつつ、全体像はトップレベルで維持し、各所への誘導を行う。
      - `GEMINI.md` は、`README.md` とは別に、AIが参照する用のドキュメントとして維持する。

### 主要コマンド

- torii-chan デプロイ: `nixos-rebuild switch --flake .#torii-chan --target-host t3u@10.0.0.1 --sudo`
- kagutsuchi-sama デプロイ: `nixos-rebuild switch --flake .#kagutsuchi-sama --target-host t3u@10.0.0.3 --sudo`
- shosoin-tan デプロイ: `nixos-rebuild switch --flake .#shosoin-tan --target-host t3u@10.0.0.4 --sudo`
- sando-kun デプロイ: `nixos-rebuild switch --flake .#sando-kun --target-host t3u@10.0.0.2 --sudo`
- 秘密情報の編集: `nix shell nixpkgs#sops -c sops secrets/secrets.yaml`
- 外部からのデプロイ (nix run 経由): `nix run nixpkgs#nixos-rebuild -- switch --flake .#<host> --target-host t3u@<IP> --sudo --ask-sudo-password`

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
- **リソース制限ホストのデプロイ**: `torii-chan` 等の低リソース機へのデプロイ時は、ネットワーク瞬断や SSH タイムアウトに注意。安定しない場合はリモート側で `nixos-rebuild` を実行する。
