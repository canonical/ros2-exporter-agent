#!/usr/bin/bash -e

STORAGE_PATH="$(snapctl get storage-base-path)"
REMOTE_SERVER_IP="$(snapctl get remote-server-ip)"
REMOTE_SERVER_PORT="$(snapctl get remote-server-port)"
DEVICE_ID="$(snapctl get device-uid)"

if [ -n "$DEVICE_ID" ]; then
    STORAGE_PATH="${STORAGE_PATH%/}/$DEVICE_ID"
    snapctl set storage-path=$STORAGE_PATH
else
    >&2 echo "DEVICE_ID is not set. Make sure it's available in the rob-cos-data-sharing snap."
fi

# We copy the private key so that we can modify the permissions. 
# The content-sharing interfce sets the permissions to 644 
# which are too loose for the key to be used safely. We cannot 
# modify the permission before because the content sharing snap
# imposes it's own permission and this snap has read-only access.
# The alternative would be to give this snap write access. 

if [ -f $SNAP_COMMON/rob-cos-shared-data/device_rsa_key ]; then
    cp $SNAP_COMMON/rob-cos-shared-data/device_rsa_key  $SNAP_USER_COMMON/
    chmod 600 $SNAP_USER_COMMON/device_rsa_key
else
    >&2 echo "could not find device_rsa_key. Make sure it's available in the rob-cos-data-sharing snap."
fi


cat > $SNAP_USER_COMMON/config <<EOF
Host storage-server
    User root
    HostName $REMOTE_SERVER_IP
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile $SNAP_USER_COMMON/device_rsa_key
EOF

echo "SSH config file and keys setup completed."

rsync -avz -e "ssh -F $SNAP_USER_COMMON/config -p $REMOTE_SERVER_PORT" --min-size=1 $SNAP_COMMON/data/ storage-server:$STORAGE_PATH
