FROM debian:11

RUN apt-get update && apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2
RUN wget -qO- https://packages.sury.org/php/apt.gpg | apt-key add - && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list