#!/bin/bash

source .env
mkdir -p auth
cat >> apache-utils <<EOF
FROM alpine
RUN apk add apache2-utils
EOF
docker build -t htpasswd -f apache-utils .
docker run --rm htpasswd htpasswd -Bbn ${AUTH_HTPASSWD_USER} ${AUTH_HTPASSWD_PASS} >> auth/htpasswd
docker image rm htpasswd
rm apache-utils


exit 0
