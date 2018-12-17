FROM        debian:stretch-slim
MAINTAINER  Emmanuel Dyan <emmanueldyan@gmail.com>

ARG         DEBIAN_FRONTEND=noninteractive
ARG         MONGODB_KEY="2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5"
ARG         MONGODB_REPO="http://repo.mongodb.org/apt/debian stretch/mongodb-org/3.6"
ARG         ELASTIC_KEY="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
ARG         ELASTIC_REPO="https://artifacts.elastic.co/packages/5.x/apt"
ARG         GRAYLOG_REPO_PACKAGE="https://packages.graylog2.org/repo/packages/graylog-2.4-repository_latest.deb"

ENV         ELASTIC_MAX_RAM 512m
ENV         GRAYLOG_MAX_RAM 512m

# Set a default conf for apt install
RUN         echo 'apt::install-recommends "false";' > /etc/apt/apt.conf.d/no-install-recommends

# Else impossible to install Java
RUN         mkdir -p /usr/share/man/man1

# Install MongoDB + ElasticSearch + Graylog
RUN         apt update && \
            # Install a few required packages
            apt install -y apt-transport-https curl dirmngr gnupg openjdk-8-jre-headless procps pwgen uuid-runtime && \
            # Setup Repo MongoDB
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv ${MONGODB_KEY} && \
            echo "deb ${MONGODB_REPO} main" > /etc/apt/sources.list.d/mongodb.list && \
            # Setup Repo ElasticSearch
            curl -sS ${ELASTIC_KEY} | apt-key add - && \
            echo "deb ${ELASTIC_REPO} stable main" > /etc/apt/sources.list.d/elastic.list && \
            # Setup Repo Graylog
            curl -L -o /tmp/graylog-repository.deb ${GRAYLOG_REPO_PACKAGE} && \
            dpkg -i /tmp/graylog-repository.deb && \
            # Install everything
            apt update && \
            apt upgrade -y && \
            apt install -y mongodb-org-server elasticsearch graylog-server && \
            apt purge --autoremove -y curl dirmngr gnupg && \
            rm -f /tmp/graylog-repository.deb && \
            rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /var/cache/* /var/log/*

# Prepare MongoDB
RUN         mkdir -p /data/mongodb /var/log/mongodb && \
            chown -R mongodb:mongodb /data/mongodb /var/log/mongodb

# Prepare GrayLog
RUN         mkdir -p /var/log/graylog-server && \
            chown -R graylog:graylog /var/log/graylog-server
RUN         GRAYLOG_PASSWORD=$(pwgen -N 1 -s 96) && \
            sed -i "s|.*password_secret.*=.*|password_secret = ${GRAYLOG_PASSWORD}|g" /etc/graylog/server/server.conf

# Prepare Elastic
RUN         sed -i 's|.*path.data:.*|path.data: /data/elasticsearch|g' /etc/elasticsearch/elasticsearch.yml
RUN         sed -i 's|.*path.logs:.*|path.logs: /var/log/elasticsearch|g' /etc/elasticsearch/elasticsearch.yml
RUN         mkdir -p /data/elasticsearch /var/log/elasticsearch
RUN         chown -R elasticsearch:elasticsearch /data/elasticsearch /var/log/elasticsearch

# Finally
EXPOSE      9000
COPY        run.sh /run.sh
RUN         chmod +x /run.sh

CMD         ["/run.sh"]
