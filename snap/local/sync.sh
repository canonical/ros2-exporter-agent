#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-base-path)"

DEVICE_ID=$(cat $SNAP_COMMON/device_id.txt)

if [ -n "$DEVICE_ID" ]; then
    STORAGE_PATH="${STORAGE_PATH%/}/$DEVICE_ID"
    snapctl set storage-path=$STORAGE_PATH
else
    echo "DEVICE_ID is not set. Make sure it's available in the rob-cos-data-sharing snap."
fi

if [ ! -d $SNAP_USER_COMMON/.ssh ]; then
    mkdir $SNAP_USER_COMMON/.ssh
fi

if [ -f $SNAP_COMMON/device_private_key ]; then
    cp $SNAP_COMMON/device_private_key  $SNAP_USER_COMMON/.ssh/
else
    echo "could not find private_key"
fi
if [ -f $SNAP_COMMON/device_public_key.pub ]; then
    cp $SNAP_COMMON/device_public_key.pub  $SNAP_USER_COMMON/.ssh/
else
    echo "could not find public key"
fi

cat > $SNAP_USER_COMMON/.ssh/config <<EOF
Host storage-server
    User ubuntu
    HostName ubuntu
    IdentityFile /root/snap/ros2-exporter-agent/common/.ssh/device_private_key
    UserKnownHostsFile /root/snap/ros2-exporter-agent/common/.ssh/known_hosts
EOF

echo "SSH config file and keys setup completed."

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config" --min-size=1 $SNAP_COMMON/ storage-server:$STORAGE_PATH
