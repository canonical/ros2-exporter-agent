#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-base-path)"
REMOTE_SERVER_IP="$(snapctl get remote-server-ip)"
REMOTE_SERVER_PORT="$(snapctl get remote-server-port)"
DEVICE_ID=$(cat $SNAP_DATA/device_id.txt)

if [ -n "$DEVICE_ID" ]; then
    STORAGE_PATH="${STORAGE_PATH%/}/$DEVICE_ID"
    snapctl set storage-path=$STORAGE_PATH
else
    >&2 echo "DEVICE_ID is not set. Make sure it's available in the rob-cos-data-sharing snap."
fi

if [ ! -f $SNAP_DATA/device_rsa_key.pub ]; then
     >&2 echo "could not find device_rsa_key.pub. Make sure it's available in the rob-cos-data-sharing snap."
else
   chmod 600 $SNAP_DATA/device_rsa_key
fi

cat > $SNAP_USER_COMMON/config <<EOF
Host storage-server
    User root
    HostName $REMOTE_SERVER_IP
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile $SNAP_DATA/device_rsa_key
EOF

echo "SSH config file and keys setup completed."

rsync -avz -e "ssh -F $SNAP_USER_COMMON/config -p 2222" --min-size=1 $SNAP_COMMON/data/ storage-server:$STORAGE_PATH
