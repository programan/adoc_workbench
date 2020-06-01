#!/bin/bash

set -x

case "$OSTYPE" in
  linux*)
    docker-compose run --rm -e LOCAL_UID=$(id -u $USER) -e LOCAL_GID=$(id -g $USER) app bash
    ;;
  *)
    docker-compose run --rm app bash
    ;;
esac
