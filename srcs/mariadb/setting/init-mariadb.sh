#!/bin/bash
set -e

echo "Starting MariaDB..."

# Create necessary directories
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Set default values
DB_PASSWORD=${DB_PASSWORD:-$DB_ROOT_PASSWORD}

# Initialize database if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First time setup - initializing database..."
    
    # Install database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm > /dev/null
    
    echo "Starting temporary MariaDB for setup..."
    # Start MariaDB temporarily for setup (with networking disabled for security)
    # This temporary instance is only used for initial database setup and will be terminated
    mysqld --user=mysql --skip-name-resolve --skip-networking &
    pid="$!"
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to start..."
    for i in {30..0}; do
        if mysqladmin ping --silent > /dev/null 2>&1; then
            break
        fi
        echo "MariaDB init process in progress..."
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo >&2 'MariaDB init process failed.'
        exit 1
    fi
    
    echo "Setting up database and users..."
    
    # Create database and users
    mysql -u root <<-EOSQL
        -- Remove anonymous users and test database
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        
        -- Create database
        CREATE DATABASE IF NOT EXISTS ${DB_NAME};
        
        -- Set root password and enable remote access
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
        
        -- Create application user
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
        
        -- Grant database privileges
        GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
        GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
        
        FLUSH PRIVILEGES;
EOSQL
    
    # Stop temporary server
    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'MariaDB init process failed.'
        exit 1
    fi
    
    echo "Database initialization completed."
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql