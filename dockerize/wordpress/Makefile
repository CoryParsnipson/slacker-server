BACKEND_NETWORK=wordpress_backend

MARIADB_TAG=11.7.1-ubi9-rc

MARIADB_CONTAINER_NAME=wordpress-mariadb-1
MARIADB_VOLUME_NAME=mariadb-volume
MARIADB_DATA_DIR=/var/lib/mysql
MARIADB_USER_NAME=mysql
MARIADB_ROOT_PASSWORD=password # this is for testing only...

# run docker compose up
up:
	docker compose up -d --build

up-proxied:
	docker compose --profile proxied up -d --build

# run docker compose down
down:
	docker compose down

delete-volumes:
	docker volume prune -af

delete-networks:
	docker network prune -f

clean:
	docker compose down -v

# bootstrap a mariadb container instance (will initialize the database on first run)
# WARNING: do not use this instance unless you've changed the environment variables
mariadb-init:
	docker volume create ${MARIADB_VOLUME_NAME}
	docker network create ${BACKEND_NETWORK} || true
	docker run -d --network ${BACKEND_NETWORK} --name ${MARIADB_CONTAINER_NAME} -v ${MARIADB_VOLUME_NAME}:${MARIADB_DATA_DIR}:Z -e MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD} -d mariadb:${MARIADB_TAG}

# use a mariadb cli to access the maraidb container database
mariadb-shell:
	docker run -it --network ${BACKEND_NETWORK} --rm mariadb mariadb -h${MARIADB_CONTAINER_NAME} -uroot -p
