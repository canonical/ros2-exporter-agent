#!/usr/bin/bash -e

STORAGE_SERVER="$(snapctl get storage-server)"

if [[ -z "${STORAGE_SERVER}" ]]; then
        echo "Please set storage-server. Exiting..."
        exit 1
fi

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ storage-server:~/$HOSTNAME/
