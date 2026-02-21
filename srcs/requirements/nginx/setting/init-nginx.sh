#!/bin/sh
set -e

# 指定されたパスにSSL証明書がまだ存在しない場合のみ自己署名証明書を生成する
if [ ! -f "${SSL_CERT}" ]; then
  mkdir -p /etc/nginx/ssl
# -x509: 自己署名証明書を作成
  # -nodes: 秘密鍵をパスワードで保護しない（Nginxが自動起動できるようにするため）
  # -days 365: 有効期限を365日に設定
  # -newkey rsa:2048: 新しい2048ビットのRSA秘密鍵を同時に生成
  # -keyout: 秘密鍵の保存先（環境変数 ${SSL_KEY} のパスへ）
  # -out: 証明書の保存先（環境変数 ${SSL_CERT} のパスへ）
  # -subj: 証明書の所有者情報（国、州、都市、組織、およびドメイン名を指定）
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${SSL_KEY}" \
    -out "${SSL_CERT}" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42/OU=42 Paris/CN=${DOMAIN_NAME}"
fi

# default.confの生成
envsubst '${DOCKER_DNS} ${DOMAIN_NAME} ${SSL_CERT} ${SSL_KEY} ${WEB_ROOT}' \
  < /etc/nginx/conf.d/default.conf.template \
  > /etc/nginx/conf.d/default.conf

# バックグラウンド回避
exec nginx -g 'daemon off;'
