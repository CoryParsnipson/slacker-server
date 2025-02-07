USER=cparsnipson
REPOSITORY=wordpress-ngnix

build:
	docker build -t ${USER}/${REPOSITORY} .

.PHONY run:
	docker run -d ${USER}/${REPOSITORY}
