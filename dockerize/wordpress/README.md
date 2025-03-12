# wordpress

Dockerized wordpress instance that uses FastCGI for php execution and nginx as a web server.

## Bootstrap Instructions

1. Populate secrets. See `secrets/README.md` for more information.

1. Make sure the domain and email are correct at the top of `compose.yaml`

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

## More useful commands

Check the Makefile for useful commands, related to bootstrapping containers.

## Further (Manual) Wordpress Configuration Recommendations

1. Change the login url from /wp-login.php (to deter hackers) with the "WPS Hide Login" plugin. I changed this to `/auth`. You can also increase the strictness of fail2ban to immediately ban every ip that now requests wp-login.php

1. Disable xmlrpc.php. See here for more information: `https://www.hostinger.com/tutorials/xmlrpc-wordpress`. Install the "Disable XML-RPC-API" plugin to do this.

1. Remove the default plugins and delete unused themes (this will speed up the website slightly).

1. Change the permalinks scheme to use post-name for better human readability of posts. (go to the Admin Dashboard > Settings > Permalinks > Permalink Structure)
