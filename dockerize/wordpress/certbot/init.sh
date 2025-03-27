#!/bin/sh

CERTBOT_CERT_DIR=/etc/letsencrypt
CERTBOT_WEBROOT=${CERTBOT_WEBROOT:-/var/www/certbot/}
CERTBOT_EMAIL=${CERTBOT_EMAIL:-root@localhost}
CERTBOT_DOMAIN=${CERTBOT_DOMAIN:-localhost}
CERTBOT_DRYRUN=${CERTBOT_DRYRUN:-0}
CERTBOT_USE_STAGING=${CERTBOT_USE_STAGING:-0}

CERTBOT_CERT_PATH=${CERTBOT_CERT_DIR}/live/${CERTBOT_DOMAIN}

echo " -- Running certbot custom init..."
echo " -- Checking for ${CERTBOT_CERT_PATH}/fullchain.pem and ${CERTBOT_CERT_PATH}/privkey.pem"

if [[ ! -f ${CERTBOT_CERT_PATH}/fullchain.pem || ! -f ${CERTBOT_CERT_PATH}/privkey.pem ]]; then
  # script is running for the first time
  echo " -- No certs detected. Applying for ssl certificate"

  if [ $CERTBOT_DRYRUN -ne 0 ]; then
    DRYRUN="--dry-run"
  fi

  if [ $CERTBOT_USE_STAGING -ne 0 ]; then
    STAGING="--test-cert"
  fi

  sleep 1 # add this in case nginx isn't ready to serve endpoints yet

  # run certonly to get certificate
  echo "certbot certonly --webroot --webroot-path ${CERTBOT_WEBROOT} --agree-tos ${DRYRUN} ${STAGING} -m ${CERTBOT_EMAIL} -n -d ${CERTBOT_DOMAIN}"
  certbot certonly --webroot --webroot-path ${CERTBOT_WEBROOT} --agree-tos ${DRYRUN} ${STAGING} -m ${CERTBOT_EMAIL} -n -d ${CERTBOT_DOMAIN}

  # if the certonly command was successful...
  if [ $? -eq 0 ]; then
    echo " -- Certificate provisioning successful. Setting up automated renewal check..."
  fi
else
  echo " -- Certbot init script already run. Skipping..."
fi

if [[ ! -f /etc/crontab ]]
  echo " -- Setting up cronjob for ssl cert renewal"

  # modified from the original command in certbot docs to check once a day at midnight
  # honestly, I think once a month would be sufficient
  SLEEPTIME=$(awk 'BEGIN{srand(); print int(rand()*(3600+1))}'); echo "0 0 * * * root sleep $SLEEPTIME && certbot renew -q" | tee -a /etc/crontab > /dev/null
else
  echo " -- Skipping cronjob setup since crontab file already exists..."
fi

# always tail this file to keep the container running indefinitely
# (this container needs to be running 24/7 for the renewal cron job)
touch $CERTBOT_WEBROOT/keep-running-file
tail -f $CERTBOT_WEBROOT/keep-running-file
