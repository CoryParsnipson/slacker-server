# nginx-proxy-manager

Using nginx-proxy-manager to manage the top level domain entrypoint into the various subdomain apps.

## Setup Instructions

1. Add required secrets (see /secrets/README.md)

1. Bring up the docker compose using `make up`

1. Log into the nginx proxy manager admin panel for the first time (use domain.com and whatever external port is mapped to 81 in the compose file).

1. Change the credentials from the default admin to a unique user account.

1. Create a proxy host for the admin panel, so you don't have to remember the port to log in to the admin panel all the time.

   > NOTE: https://github.com/NginxProxyManager/nginx-proxy-manager/issues/139  
   > Forward to the port 81 (not exposed admin port on host) using http protocol, but click to the SSL tab and create an SSL cert
   > so that the admin panel can be secured with TLS
