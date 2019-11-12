#!/bin/bash

mkdir auth
docker run \
  --entrypoint htpasswd \
  registry:2 -Bbn username password > auth/htpasswd

exit 0
