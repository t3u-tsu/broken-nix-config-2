#!/usr/bin/env bash

set -euo pipefail

# 旧マスターキーの秘密鍵（今回一時的に生成したキー）
OLD_SECRET_KEY="AGE-SECRET-KEY-1D37F2RUUKRX4TTV2L5EDE73G6JUHVHXWKSE4AGGYWY8P82YTAG6QWLH6TF"

echo "=== SOPS Master Key Rotation Tool ==="
echo "Generating a new master age keypair..."

# 新しいキーペアを生成
KEY_OUT=$(age-keygen)
NEW_SECRET_KEY=$(echo "$KEY_OUT" | grep "AGE-SECRET-KEY-" | tr -d '\r')
NEW_PUBLIC_KEY=$(echo "$KEY_OUT" | grep -o "age1[a-z0-9]\{58\}" | tr -d '\r')

echo ""
echo "------------------------------------------------------------"
echo "!!! IMPORTANT: NEW MASTER KEY GENERATED !!!"
echo "Please save the private key in a secure password manager."
echo "This key is offline and will NOT be stored anywhere in the repository."
echo ""
echo "New Public Key:  $NEW_PUBLIC_KEY"
echo "New Private Key: $NEW_SECRET_KEY"
echo "------------------------------------------------------------"
echo ""

read -rp "Have you backed up the new private key? (y/N) " -n 1
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Key rotation cancelled. Please run the script again after backing up the key."
    exit 1
fi

echo "Updating .sops.yaml with the new public key..."
# .sops.yaml 内の master_key 公開鍵を置換
sed -i "s/\(- &master_key \)\(age1[a-z0-9]\{58\}\)/\1$NEW_PUBLIC_KEY/" .sops.yaml

echo "Rotating secrets with sops updatekeys..."
# 新旧の秘密鍵を改行区切りで環境変数に設定し、updatekeys を実行
export SOPS_AGE_KEY="${OLD_SECRET_KEY}
${NEW_SECRET_KEY}"
find secrets/ -name "*.yaml" -type f -exec sops updatekeys -y {} \;

# 環境変数をクリア
unset SOPS_AGE_KEY

echo ""
echo "=== Key Rotation Completed successfully! ==="
echo "Please commit the changes in .sops.yaml and secrets/ directory."
echo "Keep the private key offline and do NOT commit it."
