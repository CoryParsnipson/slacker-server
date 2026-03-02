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

1. TBD - configure ingresses

1. TBD - need to enable WARP on the host server???
