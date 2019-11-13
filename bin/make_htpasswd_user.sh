#!/bin/bash

source .env
mkdir -p auth
docker run \
  --entrypoint htpasswd \
  registry -Bbn ${AUTH_HTPASSWD_USER} ${AUTH_HTPASSWD_PASS} >> auth/htpasswd

exit 0
