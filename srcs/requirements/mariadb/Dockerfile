FROM debian:bookworm

# 対話的なプロンプトの回避
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

COPY setting/init-mariadb.sh /init-mariadb.sh
RUN chmod +x /init-mariadb.sh
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
VOLUME ["/var/lib/mysql"]
EXPOSE 3306
ENTRYPOINT ["/init-mariadb.sh"]