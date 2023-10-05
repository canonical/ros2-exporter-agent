#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-path)"

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ storage-server:$STORAGE_PATH
