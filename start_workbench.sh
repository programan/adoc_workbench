#!/bin/bash

set -x

# docker-compose run --rm app bash
docker-compose run --rm -e LOCAL_UID=$(id -u $USER) -e LOCAL_GID=$(id -g $USER) app bash
