#!/bin/bash

NGINX_SSL_ROOT=/etc/nginx/ssl
NGINX_CERT_PATH=${NGINX_SSL_ROOT}/live/${NGINX_DOMAIN}

echo " -- Running nginx custom init script!"

# clear default image config files and copy scripts from conf.d.orig to conf.d
rm -rf ${NGINX_CONF_PATH}/*
cp /etc/nginx/conf.d.orig/* ${NGINX_CONF_PATH}
chown www-data:www-data -R ${NGINX_CONF_PATH}

echo " -- Checking for existence of ssl certificates"

SLEEP_DURATION=1
SLEEP_DURATION_MAX=300

while [[ ! -f ${NGINX_CERT_PATH}/fullchain.pem || ! -f ${NGINX_CERT_PATH}/privkey.pem ]]; do
  echo " -- No certs detected. Waiting ${SLEEP_DURATION} second(s)..."
  sleep $SLEEP_DURATION

  SLEEP_DURATION=$(( SLEEP_DURATION * 2 ))
  SLEEP_DURATION=$(( SLEEP_DURATION > SLEEP_DURATION_MAX ? SLEEP_DURATION_MAX : SLEEP_DURATION ))
done

echo " -- Certs detected. Switching to SSL config..."

rm ${NGINX_CONF_PATH}/default.conf
mv ${NGINX_CONF_PATH}/ssl.conf.disabled ${NGINX_CONF_PATH}/ssl.conf

nginx -s reload
