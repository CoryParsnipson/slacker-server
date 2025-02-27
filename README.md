# slacker-server

Home server related code and files

## slackerparadise.com Setup

The domain is currently set up to point to the server and has many subdomains configured for it. To recreate this setup as it exists now, follow these steps:

1. Bring up a linux server (using arch linux right now) and assign it a static IP in the dhcp pool of the router.

1. Setup port forwarding for port 80, 443, 22, and 9000 to this computer's IP.

   > Note: port 22 is not related to the website, but for allowing SSH access to the server. See arch linux documentation for setting up ssh, key login, and hardening.

1. Set up DNS records for the domain name to point to the external IP of the server. If using namecheap, follow these instructions to set up dynamic DNS (which allows you to link a DNS record to a non-static IP): https://www.namecheap.com/support/knowledgebase/article.aspx/595/11/how-do-i-enable-dynamic-dns-for-a-domain/

   A non-static IP is usually what you get for a residential internet connection.

1. Make a CNAME record for host 'www' off the domain (e.g. 'mynewdomain.com.').

1. Make a dynamic DNS record that points to the root: A+ Dynamic DNS record for '@' pointing to \<my-external-ip\>.

1. Make a dynamic DNS record for all subdomains under 'mynewdomain.com': A+ Dynamic DNS record for '*' pointing to \<my-external-ip\>.

   > NOTE: some would say this is unsafe, but the nginx configuration in the dockerize folders are made to issue 404 for all undefined subdomains. Doing it this way means you don't need to change the DNS config every time you want to add or modify subdomains.

1. It will probably take around 30-60 minutes for the DNS changes to kick in.

1. Install docker and docker compose. You may need to move the docker root folder into a bigger partition by changing the config file.

1. Follow instructions to bring up the dockerize/nginx-proxy-manager.

1. Create a host proxy "proxy.mynewdomain.com" and get an SSL cert for it and point it to "localhost:81" using the "http" scheme.

1. Create a second host proxy "admin.mynewdomain.com" and get an SSL cert for that too and point it to "localhost:81" using the "http" scheme.

1. The above two subdomains will let you access the admin panel of the proxy manager without having to remember the port number and also will let you access it via TLS.

1. Follow instructions to bring up the dockerize/wordpress. If you have backed up mariadb/mysql instances and volumes, now is the time to bring them out.

1. Create a host proxy "blog.mynewdomain.com" and point it to the wordpress-nginx-1 container. Get an SSL cert for it, using port 443 and force SSL.

1. Create a redirect proxy for "mynewdomain.com" and "www.mynewdomain.com" to point to "blog.mynewdomain.com" so when people access the root domain, it goes to the blog. You will also need to get an SSL cert for this too.

1. Create a redirect proxy for "wordpress.mynewdomain.com" to "blog.mynewdomain.com" if you want. This can be HTTP only, since the blog will automatically redirect to SSL so you don't need to get a separate SSL cert for it.
