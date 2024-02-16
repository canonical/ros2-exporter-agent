#!/usr/bin/bash -e

ROBOT_ID=$(cat $SNAP_COMMON/robot_id.txt)

STORAGE_PATH="~/$ROBOT_ID"

snapctl set storage-path=$STORAGE_PATH

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ storage-server:$STORAGE_PATH
