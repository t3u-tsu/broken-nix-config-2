# デスクトップ・サービス (システム層)

このディレクトリでは、デスクトップ環境のためのシステム全体のサービスとハードウェア統合を管理しています。

## 📂 サービス構成

- **`niri.nix`**: システムレベルの Niri コンポジター設定と XDG Desktop Portal の構成。
- **`greetd.nix`**: `greetd` と `tuigreet` (TUI) によるログイン管理。
- **`pipewire.nix`**: PipeWire ベースのオーディオ基盤。
- **`fcitx5.nix`**: Wayland サポートを含む Fcitx5 日本語入力環境。
- **`fonts.nix`**: システム全体のフォント設定 (Noto, Nerd Fonts)。
- **`gaming.nix`**: Steam, GameMode, およびパフォーマンス関連のゲーミングツール。
- **`default.nix`**: すべてのデスクトップ関連サービスを束ねるインデックス。
