# wordpress

Dockerized wordpress instance that uses FastCGI for php execution and nginx as a web server.

## Bootstrap Instructions

1. Populate secrets. See `secrets/README.md` for more information.

1. Run docker compose (version from Makefile):

```
make compose
```

If this is successful, you should be able to access the nginx instance at localhost port 80.

1. Tear down docker compose when done (optional)

```
make decompose
```

Note, some things like volumes will still be around after this command.

## More useful commands

Check the Makefile for useful commands, related to bootstrapping containers.
