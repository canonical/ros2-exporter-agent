#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-base-path)"

DEVICE_ID=$(cat $SNAP_COMMON/device_id.txt)

if [ -n "$DEVICE_ID" ]; then
    STORAGE_PATH="${STORAGE_PATH%/}/$DEVICE_ID"
    snapctl set storage-path=$STORAGE_PATH
else
    echo "DEVICE_ID is not set. Make sure it's available in the rob-cos-data-sharing snap."
fi

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ storage-server:$STORAGE_PATH
