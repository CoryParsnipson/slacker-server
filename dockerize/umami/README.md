# umami

Docker compose deployment of Umami, an analytics software tool.

## Setup Instructions

1. Bring up the compose file.

1. Then add the proxy host to Nginx Proxy Manager. Use "http" as the scheme, port 3000 (default umami port) and then the name of the umami app container.

1. Optionally, add a redirection host for `analytics.domain.com` to this app.

1. Browse to the new subdomain and login using the default credentials of "admin" and "umami". Change the account to something else ASAP.

1. Next is to configure Umami, following [the documentation](umami.is/docs/add-a-website).

### Integrate Umami with Wordpress

1. Install the "Integrate Umami" Wordpress plugin.

1. Add the website ID of the WordPress blog and enable umami analytics and save settings.
