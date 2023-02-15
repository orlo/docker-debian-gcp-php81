# Public Docker image

## Features 

 * PHP 8.1 via deb.sury.org
 * PHP GRPC module
 * PHP Protobuf module
 * Apache mod\_php
 * composer 

See also: https://hub.docker.com/r/socialsigninapp/docker-debian-gcp-php81/

## Building

( http_proxy stuff is optional. )

```bash
docker build \
    --build-arg=http_proxy="http://192.168.86.66:3128" \
    --build-arg=https_proxy="http://192.168.86.66:3128" \
    --no-cache \
    --rm \
    -t socialsigninapp/docker-debian-gcp-php81:latest \
    -t socialsigninapp/docker-debian-gcp-php81:$(date +%F) \
    --pull \
    .
```

## Todo

 * Link better to Debian/Debsury.org so we rebuild on change of those files
