#!/bin/bash
set -e

until mysqladmin ping -h"$DB_HOST" -u"root" -p"$DB_ROOT_PASSWORD" --silent; do
  echo "Waiting for database..."
  sleep 2
done

until redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping | grep -q "PONG"; do
  echo "Waiting for redis..."
  sleep 2
done

envsubst '${SMTP_HOST} ${SMTP_PORT} ${SMTP_FROM} ${SMTP_USER} ${SMTP_PASSWORD}' \
  < /etc/msmtprc.template \
  > /etc/msmtprc

chmod 600 /etc/msmtprc
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

if [ ! -f "$WEB_ROOT/wp-config.php" ]; then
  echo "WordPress not found. Downloading..."
  wp core download --locale=ja --allow-root --path="$WEB_ROOT"
  chown -R www-data:www-data "$WEB_ROOT"
fi

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

  chown -R www-data:www-data "$WEB_ROOT/wp-content/uploads"

  
  if ! wp plugin is-installed redis-cache --allow-root --path="$WEB_ROOT"; then
    wp plugin install redis-cache --activate --allow-root --path="$WEB_ROOT"
  fi

  wp config set WP_REDIS_HOST "$REDIS_HOST" \
    --allow-root --path="$WEB_ROOT"

  wp config set WP_REDIS_PORT "$REDIS_PORT" \
    --allow-root --path="$WEB_ROOT"

  wp config set WP_CACHE "$REDIS_CACHE" \
    --raw --allow-root --path="$WEB_ROOT"

  wp redis enable --allow-root --path="$WEB_ROOT"
fi

# PHPMailer設定をMust-Use Pluginとして追加
mkdir -p "$WEB_ROOT/wp-content/mu-plugins"
echo "<?php
/**
 * Plugin Name: SMTP Configuration
 * Description: Gmail SMTP configuration for WordPress
 */

add_action( 'phpmailer_init', function( \$phpmailer ) {
    \$phpmailer->isSMTP();
    \$phpmailer->Host       = getenv('SMTP_HOST');
    \$phpmailer->Port       = (int) getenv('SMTP_PORT');
    \$phpmailer->SMTPSecure = getenv('SMTP_SECURE');
    \$phpmailer->SMTPAuth   = true;
    \$phpmailer->Username   = getenv('SMTP_USER');
    \$phpmailer->Password   = getenv('SMTP_PASSWORD');
    \$phpmailer->From       = getenv('SMTP_FROM');
    \$phpmailer->FromName   = getenv('TITLE') ?: 'WordPress';
});" > "$WEB_ROOT/wp-content/mu-plugins/smtp-config.php"
chown www-data:www-data "$WEB_ROOT/wp-content/mu-plugins/smtp-config.php"

exec "$@"

