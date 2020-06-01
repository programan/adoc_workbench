#!/bin/bash

set -eu


case "$OSTYPE" in
  linux*)
    USER_ID=${LOCAL_UID:-9001}
    GROUP_ID=${LOCAL_GID:-9001}
    USER_NAME=${LOCAL_NAME:-writer}

    echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
    # useradd -u $USER_ID -o -m $USER_NAME
    # groupmod -g $GROUP_ID $USER_NAME
    addgroup -g $GROUP_ID -S $USER_NAME
    adduser -u $USER_ID -S -H -G $USER_NAME $USER_NAME
    export HOME=/home/${USER_NAME}
    exec su-exec ${USER_NAME} "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
