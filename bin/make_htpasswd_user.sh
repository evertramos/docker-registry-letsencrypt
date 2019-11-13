#!/bin/bash

mkdir -p auth
docker run \
  --entrypoint htpasswd \
  registry -Bbn $1 $2 > auth/htpasswd

exit 0
