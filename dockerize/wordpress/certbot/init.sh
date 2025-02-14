#!/bin/sh
CERTBOT_WEBROOT=${CERTBOT_WEBROOT:-/var/www/certbot/}
CERTBOT_EMAIL=${CERTBOT_EMAIL:-cparsnipson@gmail.com}
CERTBOT_DOMAIN=${CERTBOT_DOMAIN:-slackerparadise.com}
CERTBOT_DRYRUN=${CERTBOT_DRYRUN:-0}
CERTBOT_USE_STAGING=${CERTBOT_USE_STAGING:-0}

echo " -- Running certbot custom init..."

if [ ! -f $FIRST_RUN_DETECTION_FILE ]; then
  # script is running for the first time
  echo " -- Certbot init running for the first time..."
  touch $FIRST_RUN_DETECTION_FILE

  echo " -- Applying for ssl certificate"

  if [ $CERTBOT_DRYRUN -ne 0 ]; then
    DRYRUN="--dry-run"
  fi

  if [ $CERTBOT_USE_STAGING -ne 0 ]; then
    STAGING="--test-cert"
  fi

  # run certonly to get certificate
  echo "certbot certonly --webroot --webroot-path ${CERTBOT_WEBROOT} --agree-tos ${DRYRUN} ${STAGING} -m ${CERTBOT_EMAIL} -n -d ${CERTBOT_DOMAIN}"
  certbot certonly --webroot --webroot-path ${CERTBOT_WEBROOT} --agree-tos ${DRYRUN} ${STAGING} -m ${CERTBOT_EMAIL} -n -d ${CERTBOT_DOMAIN}

  # if the certonly command was successful...
  if [ $? -eq 0 ]; then
    # TODO: setup cronjob for certificate renewal & check
    echo "certonly successful!"
  fi
else
  echo " -- Certbot init script already run. Skipping..."
fi

tail -f ${FIRST_RUN_DETECTION_FILE}
