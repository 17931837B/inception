FROM debian:bookworm

EXPOSE 6379

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install lsb-release curl gpg

RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list

RUN apt-get -y install redis
COPY ./setting/init-redis.sh init-redis.sh
COPY ./config/redis.conf /etc/redis/redis.conf
RUN chmod +x init-redis.sh

ENTRYPOINT ["./init-redis.sh"]