# Coordinated Update System (Update Hub)

このディレクトリでは、複数の NixOS ホスト間でシステム更新を同期させるための「調整型アップデートシステム」を管理しています。

## システム構成

システムは **Producer-Hub-Consumer** モデルで動作します。

1.  **Producer (`shosoin-tan`)**: 
    - 毎日 04:00 に実行。
    - `flake update` やプラグイン更新を行い、GitHub へプッシュします。
    - 完了後、Hub に対し最新のコミット ID を通知します。
2.  **Hub (`torii-chan`)**: 
    - Producer からの通知を受け取り、最新のコミット ID を保持します。
    - 各ホストからの報告を受け取り、進捗状況を可視化します。
    - ステータス確認: `http://10.0.0.1:8080/status`
3.  **Consumer (全ホスト)**: 
    - Hub に問い合わせ、新しいコミットがあれば自動的に `nixos-rebuild switch` を実行します。
    - 実行後、自分の状態を Hub に報告します。

## ファイル構成

- **`default.nix`**: Hub サーバー（Pythonベース）の実装。`torii-chan` で動作します。
- **`client.nix`**: 各ホストで動作する自動更新ロジック。`common/default.nix` 経由で全ホストに適用されます。

## 内部構造とスクリプト

保守性向上のため、ロジックは Nix ファイルから外部ファイルへ分離されています。

- **`hub.py`**: torii-chan で動作する中心的な管理サーバー。
- **`update-client.sh`**: 全ホストで動作する、実際の Git 同期と `nixos-rebuild` を担う Bash スクリプト。
- **`receiver.py`**: 各ホストで動作し、Hub からの更新リクエストを待ち受ける Webhook レシーバー。

## 運用コマンド


### ステータスの確認 (CLI)
```bash
curl -s http://10.0.1.1:8080/status | jq
```

### 手動での更新実行
- **サービスを直接起動:**
  ```bash
  sudo systemctl start nixos-auto-update.service
  ```
- **Webhook経由でトリガー (特定のホストを更新):**
  ```bash
  # 10.0.1.1 (torii-chan), 10.0.1.3 (kagutsuchi), etc.
  curl -X POST http://<ホストIP>:8081/trigger-update
  ```
- **Hubに最新コミットを通知 (全ホストの更新を誘発):**
  ```bash
  curl -X POST -d '{"commit": "<コミットハッシュ>"}' http://10.0.0.1:8080/producer/done
  ```

### ログの確認
```bash
sudo journalctl -u nixos-auto-update.service -f
```

## メリット
- **一貫性**: 全ホストが同じコミットを適用することを保証します。
- **効率**: Producer が一度だけビルド・プッシュすることで、Consumer は公式/私設キャッシュを最大限活用できます。
- **可視化**: どのホストが更新に成功/失敗しているかが一目でわかります。
