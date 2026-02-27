# 共通設定モジュール (common/)

このディレクトリには、全ホスト、あるいは特定のホスト群で共有される NixOS 設定モジュールが含まれています。

## モジュール一覧

### 1. `default.nix`
基本となる統合モジュールです。以下のすべてを自動的に読み込みます。

### 2. `nix.nix`
Nix パッケージマネージャーの設定です。
- Experimental features (flakes, nix-command) の有効化。
- バイナリキャッシュ (Cachix) の設定。
- 信頼できるユーザー (`trusted-users`) の定義。

### 3. `time.nix`
時刻と地域の設定です。
- タイムゾーン: `Asia/Tokyo` (JST)。
- `chrony` による高精度な時刻同期の有効化。

### 4. `wireguard.nix`
WireGuard の堅牢化設定です。
- 起動時の DNS 解決失敗に備え、すべてのピア設定サービスに自動リトライ (`Restart=on-failure`) を追加します。

### 5. `local-network.nix`
LAN 内での最適化フラグ (`my.localNetwork.enable`) を提供します。
- NAT ループバック問題への対策（ドメイン名のローカル解決）を管理します。

## 運用上の重要事項

### カーネルバージョンの固定 (6.18)
2026年2月27日の `nixos-unstable` におけるカーネル 6.19.4 のデグレード（起動不能問題）を回避するため、全ホストの `boot.kernelPackages` を **6.18** 系に `lib.mkForce` で固定しています。問題が解決されるまでは、この固定を維持することを推奨します。

### IPv4 の優先設定 (`gai.conf`)
IPv6 環境下での通信安定性と速度向上のため、`/etc/gai.conf` に `precedence ::ffff:0:0/96 100` を設定し、IPv4 通信を優先するように構成されています。
