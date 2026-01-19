#!/bin/sh
set -e

if [ ! -f "${SSL_CERT}" ]; then
  mkdir -p /etc/nginx/ssl
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${SSL_KEY}" \
    -out "${SSL_CERT}" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42/OU=42 Paris/CN=${DOMAIN_NAME}"
fi

envsubst '${DOCKER_DNS} ${DOMAIN_NAME} ${SSL_CERT} ${SSL_KEY} ${WEB_ROOT}' \
  < /etc/nginx/conf.d/default.conf.template \
  > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
