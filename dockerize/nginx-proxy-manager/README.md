# nginx-proxy-manager

Using nginx-proxy-manager to manage the top level domain entrypoint into the various subdomain apps.

## Background

This compose file brings up the nginx-proxy-manager docker image to let the user configure reverse proxies running with nginx through a user-friendly GUI over the internet. The nginx-proxy-manager is managed by a third party and relies on a database (using mariadb here), and is guarded by a crowdsec container as well. There is also a metabase container that is configured alongside crowdsec to let the user monitor alerts and decisions through a user-friendly GUI.

## Setup Instructions

### Setup Compose

1. Add required secrets (see /secrets/README.md)

1. Bring up the docker compose using `make up`

### Configure Nginx Proxy Manager

1. Log into the nginx proxy manager admin panel for the first time (use domain.com and whatever external port is mapped to 81 in the compose file).

1. Change the credentials from the default admin to a unique user account.

1. Create a proxy host for the admin panel, so you don't have to remember the port to log in to the admin panel all the time.

   > NOTE: https://github.com/NginxProxyManager/nginx-proxy-manager/issues/139  
   > Forward to the port 81 (not exposed admin port on host) using http protocol, but click to the SSL tab and create an SSL cert
   > so that the admin panel can be secured with TLS

   I recommend using something like "proxy.domain.com".

1. Create a proxy host for the metabase dashboards. I recommend something like "crowdsec.domain.com" with an optional redirection host "sec.domain.com" for convenience.

1. Create a redirection host for proxy.domain.com aliases (optional).

   If you want to access the admin dashboard through a couple aliases, you can create redirection hosts to the proxy.domain.com destination. Create a redirection host that forwards to proxy.domain.com via https and uses the SSL cert of the destination domain.

   I recommend using something like "admin.domain.com".

   What this looks like is if you type in "admin.domain.com" it will redirect to "proxy.domain.com" and show the latter url in the search bar. The first time, chrome may warn you of an insecure SSL cert.

### Configure crowdsec Dashboard

1. Configure the metabase crowdsec monitoring. Once the proxy is set up, browse to the metabase url.

   According to [this page](https://www.crowdsec.net/blog/secure-docker-compose-stacks-with-crowdsec), you must log into the metabase for the first time and change the admin password from the default value. Use the credentials:

   * email: `crowdsec@crowdsec.net`
   * password: `!!Cr0wdS3c_M3t4b4s3??`

   If these account credentials don't work or the preconfigured dashboards don't show up, then that means there is something wrong with the crowdsec and metabase config in the compose file. (Check whether the paths of all the mounted volumes are correct.)

### Setup Crowdsec

Referencing these tutorials:
  1. `[https://www.crowdsec.net/blog/secure-docker-compose-stacks-with-crowdsec](https://www.crowdsec.net/blog/secure-docker-compose-stacks-with-crowdsec)`
  1. `[https://www.simplehomelab.com/crowdsec-docker-compose-1-fw-bouncer/](https://www.simplehomelab.com/crowdsec-docker-compose-1-fw-bouncer/)`

1. Install crowdsec bouncers. Download the "firewall" bouncer from the [crowdsec hub website](https://app.crowdsec.net/hub/author/crowdsecurity/remediation-components/cs-firewall-bouncer):

   Click on download and copy the link address for the right architecture (probably linux amd64).

   > NOTE: When the tutorials say "host" or "docker host" or installing something on the server as a native app, they mean to do this on the computer that docker is installed (read: not in any containers). This must be done on the server because the bouncers modify the iptables of the server itself.


   ```
   # on the machine running docker...
   wget <crowdsec bouncer download url>
   tar xvzf <crowdsec tarball>
   cd crowdsec-firewall-bouncer-v0.0.31
   sudo ./install.sh
   ```
   > NOTE: you may need to install a few utilities to successfully use, such as iptables or ipset.

   > WARNING: if you are on arch linux and install ipset, you will need to restart the computer if you run into "kernel errors" about invalid arguments.

1. Log into the crowdsec container and retrieve an api key for the bouncer.

   ```
   docker-compose exec crowdsec cscli bouncers add HostFirewallBouncer
   ```

   The name `HostFirewallBouncer` is up to you to identify the specific bouncer.

1. Copy this API key and on the docker host, edit the `/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml` file. Replace the entry "api_key" with this.

1. Also within the aforementioned file, make sure `mode` is set to `iptables` (because it looks like docker does not support using nftables).

1. Also under `iptables_chains`, make sure `INPUT` and `DOCKER-USER` are uncommented. `INPUT` applies to all incoming traffic, so if this is selected, crowdsec rules will apply to all incoming server traffic. `DOCKER-USER` means that the crowdsec rules will apply to all docker containers.

1. Lastly, make sure the `api_url` field is set to `http://localhost:8999`. This url may change depending on the exact environmental setup (see NOTE below).

   > NOTE: this needs to be localhost, because the host server needs to be able to make requests to the crowdsec container. Normally, you could make a proxy host for it in nginx proxy manager, but in my current environment, nat loopback is not supported, so that will not work. What I did instead was to expose an external port for the crowdsec container and then use localhost with that port number to get it to work.

1. Enable and start the crowdsec service (or restart it if is already running). NOTE: this runs on the server!

   ```
   sudo systemctl enable crowdsec-firewall-bouncer.service
   sudo systemctl start crowdsec-firewall-bouncer.service
   ```
   > WARNING: if you do these steps out of order (such that the crowdsec container is down but the service running on the docker host is active), you may see degraded service and lots of connection timeouts trying to access the server (or ssh'ing into it). The service should be stopped until the crowdsec container can be brought back up and have the connectivity issues and API key fixed, so the failed requests stop happening. Just something to watch out for in case the server randomly seems to stop responding to http requests altogether.

1. One may tail `/var/log/crowdsec-firewall-bouncer.log` to see if it was successful. Errors will be logged here.

1. Check the iptables configuration.

   ```
   sudo iptables -L -n | less
   ```

   Under `Chain DOCKER-USER` and `Chain INPUT`, there should be a reference that captures all traffic and forwards it to a match-set with a name like `crowdsec-blacklists` or `crowdsec-blacklists-0` or something

1. Check the ipset:

   ```
   sudo ipset -L crowdsec-blacklists-0
   ```

   This will show a list of active decisions, which consists of decisions made from your server (banned ips from suspicious activity) along with prior decisions crowd sourced from the cloud.

## Crowdsec Cheatsheet

*. Check crowdsec configuration:

   ```docker-compose exec crowdsec cscli hub list```

*. Check crowdsec metrics:

   ```docker-compose exec crowdsec cscli metrics```

*. Check on active decisions:

   ```docker-compose exec crowdsec cscli decisions list```

*. Check on alerts:

   ```docker-compose exec crowdsec cscli alerts list```

   > NOTE: viewing decisions and alerts is much nicer using the metabase dashboard instead

*. Inspect an alert in more detail:

   ```docker-compose exec crowdsec cscli alerts inspect -d <alert id>```
