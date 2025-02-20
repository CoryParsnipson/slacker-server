#!/bin/bash

echo " -- Running custom phpmyadmin init script"

# move files from default /var/www/html
echo " -- Moving phpmyadmin files from /var/www/html to /var/www/html/pma"

rm -rf /var/www/html/pma/*

shopt -s extglob
cd /var/www/html && mv !(pma) pma
shopt -s dotglob

chown -R ${PUID}:${PGID} /var/www/html/pma

# do the default image action
/docker-entrypoint.sh php-fpm
