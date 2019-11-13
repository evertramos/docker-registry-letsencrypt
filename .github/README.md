# Using Docker Registry with SSL enabled integrated with NGINX proxy and autorenew LetsEncrypt certificates

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

# Max Log File Size
LOGGING_OPTIONS_MAX_SIZE=200k

# Your domain (or domains)
DOMAINS=domain.com,www.domain.com

# Your email for Let's Encrypt register
LETSENCRYPT_EMAIL=your_email@domain.com
```

>This container must use a network connected to your webproxy or the same network of your webproxy.

3. Start your project

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
