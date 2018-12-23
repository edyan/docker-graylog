#!/usr/bin/env bash


# Set password for graylog (admin / admin)
sed -i "s|^root_password_sha2.*=.*|root_password_sha2 = 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918|g" /etc/graylog/server/server.conf
# Detect IP to listen for user to access Web GUI
#LOCAL_IP=$(hostname --ip-address)
sed -i "s|.*web_listen_uri.*=.*|web_listen_uri = http://0.0.0.0:9000|g" /etc/graylog/server/server.conf
sed -i "s|.*rest_listen_uri.*=.*|rest_listen_uri = http://0.0.0.0:9001/api/|g" /etc/graylog/server/server.conf
sed -i "s|.*rest_transport_uri.*=.*|rest_transport_uri = http://127.0.0.1:9001/api/|g" /etc/graylog/server/server.conf

# Start graylog
sed -i "s|-Xms[0-9gm]* |-Xms${GRAYLOG_MAX_RAM} |g" /etc/default/graylog-server
sed -i "s|-Xmx[0-9gm]* |-Xmx${GRAYLOG_MAX_RAM} |g" /etc/default/graylog-server
/etc/init.d/graylog-server start

# Start Elastic
# Make sure we have the right permissions
chown -R elasticsearch:elasticsearch /data/elasticsearch
# Change config
sed -i "s|^-Xms.*|-Xms${ELASTIC_MAX_RAM}|g" /etc/elasticsearch/jvm.options
sed -i "s|^-Xmx.*|-Xmx${ELASTIC_MAX_RAM}|g" /etc/elasticsearch/jvm.options
/etc/init.d/elasticsearch start

# Start mongo in foreground
# That's a trick, but that image is for dev only ;)
chown -R mongodb:mongodb /data/mongodb
/usr/bin/mongod --smallfiles --dbpath /data/mongodb

