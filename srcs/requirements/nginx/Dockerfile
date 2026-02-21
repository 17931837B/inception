FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y nginx openssl gettext-base

RUN rm -f /etc/nginx/conf.d/*
COPY ./config/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./setting/init-nginx.sh ./init-nginx.sh
RUN chmod +x ./init-nginx.sh
EXPOSE 443
ENTRYPOINT ["./init-nginx.sh"]