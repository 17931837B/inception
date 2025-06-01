FROM debian:11

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

COPY ./mariadb.cnf /etc/mysql/mariadb.conf.d/mariadb.cnf
COPY ./initdb.sh ./

RUN chmod +x ./init.sh

ENTRYPOINT ["sh", "/init.sh"]
