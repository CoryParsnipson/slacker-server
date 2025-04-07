# wordpress

Dockerized wordpress instance that uses FastCGI for php execution and nginx as a web server.

## Bootstrap Instructions

Common steps here:

1. Populate secrets. See `secrets/README.md` for more information.

1. Make sure the domain and email are correct at the top of `compose.yaml`

### Running Wordpress as a standalone app on the server

1. The rest of the steps here assume the domain and port forwarding and DNS have been setup already.

1. Run docker compose (version from Makefile):

```
make up 
```

If this is successful, you should be able to access the nginx instance at localhost port 80.

1. Log into phpmyadmin (localhost/pma) and manually follow the instructions to set up the control storage (this allows phpmyadmin to remember UI related things across sessions). Log in with "root" and the mariadb root password.

1. Tear down docker compose when done (optional)

```
make down
```

Alternatively, use `make clean` to also remove volumes and networks to completely remove all provisioned resources.

Note, some things like volumes will still be around after this command.

### Running Wordpress behind an nginx reverse proxy (like Nginx Proxy Manager)

1. Setup the reverse proxy. The steps here specifically assume you are using the Nginx Proxy Manager tool, see instructions in the nginx-proxy-manager folder.

1. Bring up the app in docker compose. You will need to use the proxied make commands instead of the default, which makes a standalone image:

```
make up-proxied
```

1. Create a proxy host to this app. The domain must match the domain at the top of `compose.yaml` (so go back and change that and remake this, if it's wrong). Select `http` as the scheme, and the name of the proxied nginx container (probably something like `wordpress-nginx-proxied-1`), and port 80. Click on the "SSL" tab and select "Create a new Certificate" to have letsencrypt get a new certificate for this. Now add an SSL cert, select "Force SSL" and "Support HTTP/2" if you want.

1. Once the SSL cert is successfully created, you should be able to browse to the app and have a working ssl cert, without the backend nginx instance needing to handle SSL connections at all.

## More useful commands

Check the Makefile for useful commands, related to bootstrapping containers.

## Further (Manual) Wordpress Configuration Recommendations

1. Change the login url from /wp-login.php (to deter hackers) with the "WPS Hide Login" plugin. I changed this to `/auth`. You can also increase the strictness of fail2ban to immediately ban every ip that now requests wp-login.php

1. Disable xmlrpc.php. See here for more information: `https://www.hostinger.com/tutorials/xmlrpc-wordpress`. Install the "Disable XML-RPC-API" plugin to do this.

1. Remove the default plugins and delete unused themes (this will speed up the website slightly).

1. Change the permalinks scheme to use post-name for better human readability of posts. (go to the Admin Dashboard > Settings > Permalinks > Permalink Structure)

## Installing the Wordpress Crowdsec bouncer

It is highly recommended to integrate the wordpress bouncer with crowdsec, if that is available.

1. Install the crowdsec wordpress plugin (install and activate through the admin dashboard)

1. Use the crowdsec container and port as the crowdsec endpoint. Something like `http://entry-crowdsec-1:8080`, note that the port name is the container's port and not the externally exposed port.

1. Add the API key in the crowdsec plugin page. Use `cscli bouncer add cs-wordpress-bouncer` in the crowdsec container to get an API key.

1. Toggle the "Use cURL to call Local API" to `on`. Since this is on a separate container, we will need to use the curl function. This requires curl to be installed on the crowdsec container (it should be). You can scroll down and click "Test bouncing" to see if the curl method is working.

1. Disable WP internal cron (if loopback NAT curl is failing) by going to wp-config.php and adding `DEFINE( 'DISABLE_WP_CRON', true );` to the file.

   > NOTE: if the curl loopback is working, the wp-cron container is not needed at all and can be removed.

1. Use 10 seconds for a timeout to make it snappy. Set level to "normal bouncing" and make sure that "public website only" is `off`, so the admin dashboard is also protected.

1. Under the "Advanced" tab of the crowdsec plugin settings, you can enable "stream" mode (there apparently is no downside to having this on).

1. Set "Enable usage metrics" so that the bouncer will send data back to `app.crowdsec.net`.

1. Add the nginx proxy manager container IP to the "Trust these CDN IPs" field. Something like `172.18.0.x` probably. This is needed so that crowdsec can trust the forwarded ip header coming from this computer and bounce using the correct IP.

   > NOTE: You can go into the wordpress or nginx container and go into `/var/www/html/wp-content/uploads/crowdsec/logs` to see `debug.log` or `prod.log` to find messages pertaining to the wordpress crowdsec plugin. Verify that there are no messages like `Detected IP is not allowed for X-Forwarded-for usage|{"type":"NON_AUTHORIZED_X_FORWARDED_FOR_USAGE"...` in the log. (Otherwise, double check that this step is done correctly.)
