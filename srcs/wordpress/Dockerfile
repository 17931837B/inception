FROM debian:bookworm

EXPOSE 9000

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install curl php8.2 php8.2-mysql php8.2-fpm php8.2-gd mariadb-client redis-tools gettext-base msmtp && \
    rm -rf /var/lib/apt/lists/*

COPY ./config/www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN mkdir -p /var/www/html
RUN mkdir -p /run/php

COPY ./config/msmtprc.template /etc/msmtprc.template
RUN chmod 600 /etc/msmtprc.template

COPY setting/init-wp.sh /init-wp.sh
RUN chmod +x /init-wp.sh

ENTRYPOINT ["/bin/bash", "/init-wp.sh"]
CMD ["php-fpm8.2", "-F"]
