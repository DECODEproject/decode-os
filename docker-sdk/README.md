# DECODE OS - Docker facility


[![Powered by DECODE OS](https://decodeos.dyne.org/img/decodeos_logo-800px.jpg)](https://decodeos.dyne.org)

The DECODE operating system is a brand new GNU+Linux distribution designed to run on servers, embedded computers and virtual machines to automatically connect micro-services to a private and anonymous peer-to-peer network cluster.

This is a Docker build of it to facilitate development and testing.

## DO NOT USE IN PRODUCTION

This Docker image is provided only for testing and showcase. We do release DECODE OS images for use in production on https://files.dyne.org/decode

In order to test DECODE OS in Docker is possible to get the latest image with:
```
docker pull dyne/decodeos:latest
```

And then run it with:
```
docker run -it -p 9150 -p 9001:9001 -p 8081:8081 -p 19999:19999 dyne/decodeos:latest
```

Then connect to the web interfaces to monitor the functioning of DECODE OS:
- http://localhost:9001 to supervise the daemons running and their logs
- http://localhost:8081 to access the list of nodes and their values
- http://localhost:19999 to monitor the resource usage

At last, you can use localhost port 9150 using Socks5 connections to be routed through Tor. Your application may then interact with the listed nodes.

## Build

To re-build this docker image:
```
docker build dyne/decodeos:local .
```

