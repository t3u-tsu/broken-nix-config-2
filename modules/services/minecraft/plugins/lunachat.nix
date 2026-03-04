{ ... }:

{
  # LunaChat の共通設定 (v3.0.16 対応)
  # どのサーバーでも同じ設定を適用するためにモジュール化
  
  # 設定ファイルの内容を定義
  # 各サーバーの services.minecraft-servers.servers.<name>.files にマージされることを想定
  config.lunaChatConfig = {
    configVersion = 3;
    japanize-chat = true;
    japanize-convert-type = "GoogleIME";
    default-japanize-on = "on";
    # 表示形式の設定: 1行にまとめ、 ローマ字 (日本語) の形式にする
    japanizeDisplayLine = 1;
    "japanize-line-format" = "%msg (%japanize)";
    # 必須項目: これがないと NullPointerException で落ちる
    ngword = [ ];
    ngword-action = "mask";
  };
}
