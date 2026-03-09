# Niri 設定

このディレクトリでは、Niri スクロール型タイル Wayland コンポジターとそのエコシステムを管理しています。

## 📂 コンポーネント

- **`default.nix`**: Niri のコア設定。レイアウト、ウィンドウ構成、キーバインド（Omarchy + Vim スタイル）を含みます。
- **`noctalia.nix`**: ステータスバーやランチャーを提供する `noctalia-shell` との統合。
- **`addons.nix`**: 周辺ツール群（`fuzzel`, `swaync`, `swayosd`, `nautilus`）。
- **`power.nix`**: `hyprlock` と `hypridle` による電源管理と画面ロック。

## ⌨️ 主要キーバインド

- `Mod + Return`: ターミナル (Alacritty)
- `Mod + Shift + B`: ブラウザ (Zen Browser)
- `Mod + Space`: ランチャー (Noctalia)
- `Mod + W`: ウィンドウを閉じる
- `Mod + H/J/K/L`: 移動・操作 (Vim スタイル)
- `Mod + 矢印キー`: 移動・操作 (標準)
- `Mod + V`: フローティングの切り替え
