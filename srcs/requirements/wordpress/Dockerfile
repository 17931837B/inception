FROM debian:bookworm

EXPOSE 9000

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install curl php8.2 php8.2-mysql php8.2-fpm php8.2-gd mariadb-client gettext-base && \
    rm -rf /var/lib/apt/lists/*

COPY ./config/www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
RUN mkdir -p /var/www/html
RUN mkdir -p /run/php
COPY setting/init-wp.sh /init-wp.sh
RUN chmod +x /init-wp.sh
ENTRYPOINT ["/bin/bash", "/init-wp.sh"]
CMD ["php-fpm8.2", "-F"]