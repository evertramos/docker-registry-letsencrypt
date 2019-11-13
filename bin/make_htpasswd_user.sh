#!/bin/bash

mkdir -p auth
docker run \
  --entrypoint htpasswd \
  registry:2 -Bbn $1 $2 > auth/htpasswd

exit 0
