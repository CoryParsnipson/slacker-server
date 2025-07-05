# planka

This is an open source "Planka Kanban" package as an alternative to Trello. This software lets you generate tasks and move them across a "scrum-like" board to track progress.

# Setup

1. Fill out the secrets. See the README.md in that directory for more information.
1. Make sure you have the BASE_URL variable set properly. This is a little tricky if you are behind a reverse proxy, especially Nginx Proxy Manager.

   > NOTE: for example, the BASE URL should be whatever the user types in the address bar to get to the app. For nginx proxy manager, this would be something like `https://planka.my-domain.net`. Note that the port number has been left out, since it's been left at the default of 80. Do not leave out the `https` protocol.

1. Make sure Nginx Proxy Manager has websocket support enabled when you create the proxy host! The proxy host also needs to have "Force SSL" and "Http/2" support enabled. You need an SSL certificate for this.

   > WARNING: If the page is loading forever after logging in, check to make sure the proxy settings and BASE_URL are correct.

1. After bringing up the app, go to the `data` directory and make sure all files except `db-data` have 1000:1000 as the owner. If not, change them all using `sudo chown 1000:1000`. Change the owner of `db-data` to 70:root

   > WARNING: if you can't upload files or change the avatar and you are getting 422 http status code responses, check the folder permissions.

1. I added redirect hosts in NPM for things like `kanban.domain.io` and `trello.domain.io`.
