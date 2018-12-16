#!/usr/bin/env bash


# Set password for graylog (admin)
sed -i "s|^root_password_sha2.*=.*|root_password_sha2 = 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918|g" /etc/graylog/server/server.conf
# Detect IP to listen for user to access Web GUI
LOCAL_IP=$(hostname --ip-address)
sed -i "s|.*web_listen_uri.*=.*|web_listen_uri = http://${LOCAL_IP}:9000|g" /etc/graylog/server/server.conf
sed -i "s|.*rest_listen_uri.*=.*|rest_listen_uri = http://${LOCAL_IP}:9000/api/|g" /etc/graylog/server/server.conf

# Start graylog
/etc/init.d/graylog-server start

# Start Elastic
/etc/init.d/elasticsearch start

# Start mongo in foreground
# That's a trick, but that image is for dev only ;)
/usr/bin/mongod --smallfiles --dbpath /data/db
