# BrokenPC

ハイブリッドGPU構成を持つNixOSデスクトップマシン。

## ハードウェア
- **CPU**: AMD Ryzen (Radeon Graphics内蔵)
- **GPU**: NVIDIA GeForce RTX 3050 Laptop (故障中 - 画面出力のみに使用し、重い描画処理は行わない)
- **ディスク**: NVMe SSD (512GB)

## 設定の特徴
- **デスクトップ**: KDE Plasma 6 (Wayland)
- **ハイブリッドグラフィックス**: 
  - デフォルトで NVIDIA PRIME Offload を使用。
  - 故障した NVIDIA GPU でのクラッシュを避けるため、描画処理は AMD 内蔵 GPU が担当。
  - NVIDIA は外部モニターへの画面出力パスとしてのみ機能。
- **Specialisation (特製モード)**: 
  - `No-NVIDIA`: 緊急時や安全性を優先する場合に、NVIDIA ドライバを完全に無効化して起動するモード。

## デプロイ
```bash
sudo nixos-rebuild switch --flake .#BrokenPC
```
