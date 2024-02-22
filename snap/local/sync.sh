#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-base-path)"

ROBOT_ID=$(cat $SNAP_COMMON/robot_id.txt)

if [ -n "$ROBOT_ID" ]; then
    STORAGE_PATH="${STORAGE_PATH%/}/$ROBOT_ID"
    snapctl set storage-path=$STORAGE_PATH
fi

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ storage-server:$STORAGE_PATH
