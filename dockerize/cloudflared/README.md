# cloudflared

If you are in a situation where you don't control the router, you can still host a server using cloudflare tunnels as a proxy for inbound connections directly to your server. This requires signing up for a cloudflare account (free tier is fine), then using cloudflare dns servers as a proxy in the namecheap dns servers config.

What is now known as "cloudflare tunnels" used to be called "argo tunnels".

## background

See [the cloudflare blog post about argo tunnels](https://blog.cloudflare.com/argo-tunnels-that-live-forever/) for an introduction.

## prerequisites

1. Create [cloudflare account](https://dash.cloudflare.com/sign-up. You can select the free tier.

## tunnel configuration

1. Log in to the cloudflare dashboard and set up a domain. Click the "Onboard a domain" button and type in the domain to tunnel to.

1. Once you hit continue, Cloudflare will automatically scrape the DNS records from existing provider. The rest of this document assumes the domain is registered to Namecheap. The DNS records copied over should be fine, just change to the IP address in the relevant records.

   > NOTE: more information [here](https://www.namecheap.com/support/knowledgebase/article.aspx/9607/2210/how-to-set-up-dns-records-for-your-domain-in-a-cloudflare-account/)

   > NOTE: once Cloudflare copies DNS records, the DNS records on Namecheap will no longer take effect. They can be deleted (but it might be easier to keep them there in case one moves away from cloudflare tunnels in the future).

1. In the Namecheap dashboard, log in and browse to the Domain List, then click "Manage" on the relevant domain. Down at the section that says "Nameservers", click the drop down arrow and select "Custom DNS". Then add in the two nameservers provided by cloudflare. This will take up to 48 hours to take effect.

1. On the arch linux server, run `cloudflared tunnel login`. This will open a browser window for you to login with your account.

   > NOTE: if arch is running headless, it may be recommended to run on a GUI desktop environment and ssh into the server.

1. Once logged into the cloudflare dashboard, browse to "Zero Trust" (on the left hand sidebar) > "Networks" > "Overview" > "Manage Tunnels" (on the top center) > "Add a Tunnel"

1. Create a tunnel through the dashboard and the next page will show you a couple commands to get it started on a host machine. Ignore these, but copy the token id because we need that.

1. Add the tunnel token as a secret for the compose file. 

1. Docker compose up -d the compose file and it should start.

1. Next add routes to published local apps through the cloudflare zero trust dashboard. The first route to add should be the one to the nginx proxy manager admin page, so you can fix everything else.

   Add a route to subdomain "admin" and domain as <mydomain.com> and point it to the npm admin entry point. (Mine was the docker container called "entry-proxy-1" port 81). This should also cause cloudflare to automatically create a DNS CNAME record from "admin" to the cloudflare tunnel under Dashboard > DNS > Records. If this does not happen, you should create this manually.

   To create manually, click "Add Record", select CNAME as record type, use "admin" for the name, and then type in the <tunnel id>.cfargotunnel.com as the ipv4 address.

   > NOTE: To find the tunnel id, go to the zero trust dashboard, and browse on the left hand side to Networks > Connectors. The tunnel id should be listed under the "Tunnel ID" column.

1. Because of the DNS records, this previous step should take 5-ish minutes to propagate. You can check the logs of the cloudflared docker container to see if the ingress rules have been updated.

   Once everything looks good, browse to `http://admin.<mydomain.com>`, note the HTTP not using SSL. This might take some extra fiddling around and maybe restarting the docker containers, but the NPM login screen should pop up eventually.

1. Once this is working, it's time to add the rest of the ingress and DNS record routes.

   Add the wildcard ingress route for the tunnel. Put in "*" as the subdomain, and "\<tunnel_id\>.cfargotunnel.com" as the ipv4 field and point to `http://entry-proxy-1` or whatever the NPM http entrypoint is bound to.

   > NOTE: This will not create an associated DNS record because it's using a wildcard. It should already be added by the tunnel setup, so we are good here.

1. Lastly, you need to add the root DNS record (for when someone types in <domainname.com> without any prefix). Add a new DNS record with type CNAME, use <mydomain.com> as the name, and then use "\<tunnel_id\>.cfargotunnel.com" as the target.

1. Browse to the NPM admin control panel and change all proxy hosts settings to make sure "Force SSL" is unchecked, since cloudflare is now handling SSL. Once that is done, everything should be working again!
