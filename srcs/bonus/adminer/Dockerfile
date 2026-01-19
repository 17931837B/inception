FROM debian:bookworm

EXPOSE 8080

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install adminer apache2 php libapache2-mod-php && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./config/ports.conf /etc/apache2/ports.conf
COPY ./config/fqdn.conf /etc/apache2/conf-available/fqdn.conf
COPY ./config/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./setting/init-adminer.sh ./init-adminer.sh
RUN chmod +x ./init-adminer.sh

RUN a2enconf adminer
RUN a2enconf fqdn
RUN a2ensite 000-default

ENTRYPOINT [ "./init-adminer.sh" ]