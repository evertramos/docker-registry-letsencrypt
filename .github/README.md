# Using Docker Registry with Basic Auth and SSL enabled integrated with NGINX proxy

This docker-compose should be used with WebProxy (the NGINX Proxy):

[https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion)

## Prerequisites

- DNS of your domain pointed to the Public IP address of your server
- [Proxy](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion) configured in your server

## Usage

1. Clone this repository:

```bash
git clone https://github.com/evertramos/docker-registry-letsencrypt.git
```

Or just copy the content of `docker-compose.yml` and the `.env` file, as of below:

```bash
version: '3'

services:
    
   my-registry:
     container_name: ${CONTAINER_REGISTRY_NAME}
     image: registry:${REGISTRY_VERSION:-latest}
     restart: unless-stopped
     volumes:
       - ${REGISTRY_FILES_PATH}:/var/lib/registry
       - ${REGISTRY_AUTH_PATH}:/auth/
     environment:
       REGISTRY_AUTH: htpasswd
       REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
       REGISTRY_AUTH_HTPASSWD_PATH: ${REGISTRY_AUTH_HTPASSWD_PATH}
       VIRTUAL_PORT: 5000
       VIRTUAL_HOST: ${DOMAINS}
       LETSENCRYPT_HOST: ${DOMAINS}
       LETSENCRYPT_EMAIL: ${LETSENCRYPT_EMAIL}
     logging:
       options:
         max-size: ${LOGGING_OPTIONS_MAX_SIZE:-200k}

networks:
    default:
       external:
         name: ${NETWORK}
```

2. Make a copy of our .env.sample and rename it to .env:

Update this file with your preferences.

```bash
#
# .env file to set up your Docker Registry
#

#
# Registry Version
#
# It is recommended that you always set your version to your containers
# Please be carefull on changeing versions
#
#REGISTRY_VERSION=2.7.1

#
# Network name
# 
# Your container app must use a network conencted to your webproxy 
# https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion
#
NETWORK=webproxy

#
# Database Container configuration
# We recommend MySQL or MariaDB - please update docker-compose file if needed.
#
CONTAINER_REGISTRY_NAME=registry

# Path to store your registry files
REGISTRY_FILES_PATH=./../data

# Path to store your auth registry files
REGISTRY_AUTH_PATH=./auth
REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd

# Login Information
AUTH_HTPASSWD_USER=your_email@domain.com
AUTH_HTPASSWD_PASS=very,secret,password123

# Max Log File Size
LOGGING_OPTIONS_MAX_SIZE=200k

# Your domain (or domains)
DOMAINS=domain.com,www.domain.com

# Your email for Let's Encrypt register
LETSENCRYPT_EMAIL=your_email@domain.com
```

>This container must use a network connected to your webproxy or the same network of your webproxy.

5. Create your *htpasswd* file

```bash
./bin/make_htpasswd_user.sh
```

4. Start your project

```bash
docker-compose up -d
```
----

**Be patient** - when you first run a container to get new certificates, it may take a few minutes.

You could follow the certificate creation running the command:

```bash
docker logs --tail 50 --follow nginx-letsencrypt
```
Where "nginx-letsencrypt" is the name of your Letsencrypt container settled in the proxy.

----

## Connecting to your Registry

As we are using Basic Auth you must login to your registry using the *AUTH_HTPASSWD_USER* and *AUTH_HTPASSWD_PASS* you set in your .env file

```bash
docker login registry.domain.com
```

## Testing

> This testing mode was adapted from the docker documentation [https://docs.docker.com/registry/deploying/](https://docs.docker.com/registry/deploying/)

### Copy an image from Docker Hub to your registry

You can pull an image from Docker Hub and push it to your registry. The following example pulls the **alpine** image from Docker Hub and re-tags it as my-alpine, then pushes it to your registry (substitute the url *registry.domain.com* to your correct domain configred in your .env file). Finally, the alpine and my-alpine images are deleted locally and the my-alpine image is pulled from the local registry.

1. Pull the alpine image from Docker Hub

```bash
docker pull alpine
```` 

2. Tag the image as registry.domain.com/my-alpine. This creates an additional tag for the existing image. When the first part of the tag is a hostname and port (if applicable), Docker interprets this as the location of a registry, when pushing

```bash
docker tag ubuntu:16.04 localhost:5000/my-ubuntu
```

3. Push the image to your registry running at registry.domain.com:

```bash
docker push registry.domain.com/my-alpine
```

4. Remove the locally-cached alpine and registry.domain.com/my-alpine images, so that you can test pulling the image from your registry. This does not remove the registry.domain.com/my-alpine image from your registry

```bash
docker image remove alpine
docker image remove registry.domain.com/my-alpine
```

5. Pull the registry.domain.com/my-alpine image from your local registry

```bash
docker pull registry.domain.com/my-alpine
```
