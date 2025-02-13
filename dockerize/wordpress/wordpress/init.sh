#!/bin/bash

echo "Running custom wordpress init script..."

set -m

# now run the original command from the wordpress image
docker-entrypoint.sh php-fpm & async_pid=$!

# wait for entrypoint script to copy wordpress files to base location
sleep 2

# create fonts directory and make it writable by wordpress
cd ${WORDPRESS_DATA_DIR}
mkdir -p wp-content/uploads/fonts
chown -R www-data:www-data wp-content/uploads

# foreground the entrypoint process
wait "$async_pid"
