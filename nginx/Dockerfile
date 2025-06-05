FROM debian:11

RUN apt-get update && apt-get install -y openssl nginx curl vim sudo

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=JP/ST=Tokyo/l=Shinjuku/O=42/OU=tobaba/CN=tobaba.42.fr" -newkey rsa:2048

COPY ./nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]