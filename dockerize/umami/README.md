# umami

Docker compose deployment of Umami, an analytics software tool.

## Setup Instructions

1. Bring up the compose file.

1. Then add the proxy host to Nginx Proxy Manager. Use "http" as the scheme, port 3000 (default umami port) and then the name of the umami app container.

1. Optionally, add a redirection host for `analytics.domain.com` to this app.

1. Browse to the new subdomain and login using the default credentials of "admin" and "umami". Change the account to something else ASAP.

1. Next is to configure Umami, following [the documentation](umami.is/docs/add-a-website).

### Integrate Umami with Wordpress

1. Install the WPCode snippets plugin.

1. Create one HTML snippet and add the following as the content:

   ```
   <script src="url-to-your-umami-script" data-website-id="your-umami-website-id"></script>
   <script src="/wp-content/uploads/umami-kit/umami-kit.js"></script>
   ```

   > NOTE: replace the "url-to-your-umami-script" and "your-umami-website-id" with the url and website id of your umami instance. More information can be found in the umami docs.

   > NOTE: The second script line relies on umami kit being installed. There is a small change in the wordpress docker `init.sh` script where we download umami-kit to a subdirectory in wp-content that this line relies on.

1. Call this script something like "Include Umami Kit". Make sure it is "Auto Insert" and then change the location to "Site Wide Footer".

1. Press save or update to save the changes.

1. Create another snippet that is Javascript and call it something like "Umami Kit Integration".

1. Populate the body with manual javascript umami kit instantiation, as depicted in [the Umami Kit docs](https://github.com/rhelmer/umami-kit).

   > WARNING: The class name of `UmamiKit` may have been changed to `UmamiTracker`, so the code example may need to be updated accordingly.

1. Make sure it is "Auto Insert" and then change the location to "Site Wide Footer".

1. Change the priority to higher than 10, so it executes after the previous snippet.
