BACKEND_NETWORK=test-network

MARIADB_TAG=11.7.1-ubi9-rc

MARIADB_CONTAINER_NAME=mariadb-test
MARIADB_VOLUME_NAME=wordpress-mariadb
MARIADB_DATA_DIR=/var/lib/mysql
MARIADB_ROOT_PASSWORD=password # this is for testing only...

# bootstrap a mariadb container instance (will initialize the database on first run)
mariadb-init:
	docker volume create ${MARIADB_VOLUME_NAME}
	docker network create ${BACKEND_NETWORK} || true
	docker run -d --network ${BACKEND_NETWORK} --name ${MARIADB_CONTAINER_NAME} -v ${MARIADB_VOLUME_NAME}:${MARIADB_DATA_DIR}:Z -e MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD} -d mariadb:${MARIADB_TAG}

# use a mariadb cli to access the maraidb container database
mariadb-shell:
	docker run -it --network ${BACKEND_NETWORK} --rm mariadb mariadb -h${MARIADB_CONTAINER_NAME} -uroot -p
