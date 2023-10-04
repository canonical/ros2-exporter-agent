#!/usr/bin/bash -e

STORAGE_SERVER="$(snapctl get storage-server)"

if [[ -z "${STORAGE_SERVER}" ]]; then
        echo "Please set storage-server. Exiting..."
        exit 1
fi

if ! snapctl is-connected ssh-keys; then
    echo "ssh-keys is not connected, please run: snap connect $SNAP_NAME:ssh-keys. Exiting..."
    exit 1
fi

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ $STORAGE_SERVER:~/$HOSTNAME/
