#!/bin/bash
set -e

# MariaDBの起動待機
until mysqladmin ping -h"$DB_HOST" -u"root" -p"$DB_ROOT_PASSWORD" --silent; do
  echo "Waiting for database..."
  sleep 2
done

# WordPress設定
if [ ! -f "$WEB_ROOT/wp-config.php" ]; then
  echo "WordPress not found. Downloading..."
  wp core download --locale=ja --allow-root --path="$WEB_ROOT"
  chown -R www-data:www-data "$WEB_ROOT"
fi

# wp-config.phpの作成とMariaDBとの連携
if [ ! -f "$WEB_ROOT/wp-config.php" ]; then
  wp config create \
    --allow-root \
    --path="$WEB_ROOT" \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST"
  
  wp core install \
    --allow-root \
    --path="$WEB_ROOT" \
    --url="$ORIGIN_URL" \
    --title="$TITLE" \
    --admin_name="$AD_NAME" \
    --admin_password="$AD_PASSWORD" \
    --locale="$LOCALE" \
    --admin_email="$AD_EMAIL"
  
  wp user create \
    "$USER_NAME" "$USER_EMAIL" \
    --allow-root \
    --path="$WEB_ROOT" \
    --user_pass="$USER_PASSWORD" \
    --role="$USER_AUTH"
fi

# CMD ["php-fpm8.2", "-F"]これが来る
exec "$@"