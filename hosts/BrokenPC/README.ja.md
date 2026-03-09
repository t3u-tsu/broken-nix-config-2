# ホスト: BrokenPC (Victus by HP 16-e1xxx)

ハイブリッドGPU構成を持つNixOSデスクトップマシン。日常業務と開発に使用されるHP Victus 16ゲーミングノートPC。

## ハードウェア仕様
- **CPU**: AMD Ryzen 7 6800H (16スレッド)
- **GPU**: 
  - NVIDIA GeForce RTX 3050 Ti Mobile (独立GPU - **ハードウェア故障あり**)
  - AMD Radeon 680M (内蔵GPU)
- **RAM**: 16GB DDR5
- **ストレージ**: 512GB NVMe SSD (`nvme-MTFDKBA512TFH-1BC1AABHA_UMDMC01ZRH9LRX`)

## 🚀 インストールガイド (クリーンインストール)

故障したNVIDIA GPUとハイブリッドグラフィックスの特性を考慮し、以下の手順でインストールを行ってください。

### フェーズ 1: ディスクの準備
1. **NixOSインストーラUSBから起動。**
2. **ネットワーク設定:** Wi-Fiまたは有線LANに接続。
3. **Diskoの実行:** 
   ```bash
   nix build .#nixosConfigurations.BrokenPC.config.system.build.diskoScript
   sudo ./result --mode zap_create_mount
   ```

### フェーズ 2: 秘密鍵の転送 (任意)
秘密情報（Sops）を使用する場合、ageキーを転送します。
```bash
sudo mkdir -p /mnt/var/lib/sops-nix
# /mnt/var/lib/sops-nix/key.txt に秘密鍵をコピー
```

### フェーズ 3: システムインストール
```bash
sudo NIXPKGS_ALLOW_UNFREE=1 nixos-install --flake .#BrokenPC
```

## 🔐 設定の特徴

### ハイブリッドグラフィックス管理
このマシンの独立NVIDIA GPUは、高負荷時や電力状態の遷移時にシステムクラッシュを引き起こすハードウェア故障を抱えています。
- **デフォルト (PRIME Offload):** 描画処理は安定したAMD内蔵GPUが担当します。NVIDIAは、HDMI経由で外部モニター（ASUS VP248）へ映像を出力するための「窓口」としてのみ動作し、低負荷なアイドル状態を維持します。
- **保守的な電力設定:** 電圧変化によるクラッシュを防ぐため、細かい電力管理（Fine-grained power management）は無効化されています。
- **Nouveauのブラックリスト化:** オープンソースの `nouveau` ドライバは初期化時に不安定になるため、厳格に禁止されています。

### Specialisation: No-NVIDIA モード
systemd-bootメニューに `No-NVIDIA` というエントリが用意されています。このモードは：
- すべてのNVIDIA関連カーネルモジュールをブラックリスト化します。
- システムを `amdgpu` のみで動作させます。
- 外部モニターが不要な場合や、究極の安定性が必要な場合に推奨されます。

### サービスと統合
- **デスクトップ環境:** KDE Plasma 6 (Wayland) 日本語環境。
- **Update Hub:** クライアントとして設定され、`shosoin-tan` からの更新通知を受け取ります。
- **ハードウェアツール:** `pc-tools` が有効化されており、ローカルなハードウェア管理が可能です。

## ⚠️ 注意事項
- **外部モニター:** HDMI端子は物理的にNVIDIA GPUに直結されています。外部モニターを使用するには、デフォルトモードで起動する必要があります（No-NVIDIAモードでは映りません）。
- **`nvidia-offload` コマンド禁止:** アプリケーションをNVIDIA GPUで実行しようとすると、ハードウェアがクラッシュします。絶対に実行しないでください。
