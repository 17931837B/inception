#!/bin/bash
set -e

# 実行に必要なディレクトリの作成と権限設定
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# データベースが未初期化の場合のみ実行
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # 初期設定用のSQLファイルを一時的に作成
    # rootパスワード設定、不要なユーザー削除、DB作成、アプリ用ユーザー作成を一括で行う
    cat << EOF > /tmp/setup.sql
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # ブートストラップモード（サーバーを立てずにSQL実行）で初期化を完了させる
    mysqld --user=mysql --bootstrap < /tmp/setup.sql
    rm -f /tmp/setup.sql
fi

# メインプロセスの起動（execによりPID 1として実行）
echo "Starting MariaDB server..."
exec mysqld --user=mysql