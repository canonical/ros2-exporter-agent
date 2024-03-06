#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-base-path)"

DEVICE_ID=$(cat $SNAP_COMMON/device_id.txt)

if [ -n "$DEVICE_ID" ]; then
    STORAGE_PATH="${STORAGE_PATH%/}/$DEVICE_ID"
    snapctl set storage-path=$STORAGE_PATH
else
    >&2 echo "DEVICE_ID is not set. Make sure it's available in the rob-cos-data-sharing snap."
fi

if [ ! -d $SNAP_USER_COMMON/.ssh ]; then
    mkdir $SNAP_USER_COMMON/.ssh
fi

if [ -f $SNAP_COMMON/device_rsa_key ]; then
    cp $SNAP_COMMON/device_rsa_key  $SNAP_USER_COMMON/.ssh/
else
    >&2 echo "could not find device_rsa_key"
fi
if [ -f $SNAP_COMMON/device_rsa_key.pub ]; then
    cp $SNAP_COMMON/device_rsa_key.pub  $SNAP_USER_COMMON/.ssh/
else
    >&2 echo "could not find device_rsa_key.pub"
fi

cat > $SNAP_USER_COMMON/.ssh/config <<EOF
Host storage-server
    User root
    HostName 10.166.108.243
    IdentityFile /root/snap/ros2-exporter-agent/common/.ssh/device_rsa_key
    UserKnownHostsFile /root/snap/ros2-exporter-agent/common/.ssh/known_hosts
EOF

echo "SSH config file and keys setup completed."

rsync -avz -e "ssh -F $SNAP_USER_COMMON/.ssh/config -p 2222" --min-size=1 $SNAP_COMMON/ storage-server:/var/lib/caddy-fileserver/$STORAGE_PATH
