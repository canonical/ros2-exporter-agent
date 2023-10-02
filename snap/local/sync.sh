#!/usr/bin/bash -e

STORAGE_SERVER="$(snapctl get storage-server)"
STORAGE_USER="$(snapctl get storage-user)"

if [[ -z "${STORAGE_SERVER}" ]] || [[ -z "${STORAGE_USER}" ]]; then
        echo "Please set storage-server and storage-user. Exiting..."
        exit 1
fi

if ! snapctl is-connected ssh-keys; then
    echo "ssh-keys is not connected, please run: snap connect $SNAP_NAME:ssh-keys. Exiting..."
    exit 1
fi

# StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null are necessary because the ssh-key plug is read only and .ssh/known_hosts must be extended and checked.
rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --min-size=1 $SNAP_COMMON/ $STORAGE_USER@$STORAGE_SERVER:~/$HOSTNAME/
