#!/usr/bin/bash -e

echo "Reading configuration yaml from configuration snap."

CONFIGURATION_FILE_PATH=$SNAP_COMMON/configuration/ros2-data-exporter.yaml

if [ ! -f "$CONFIGURATION_FILE_PATH" ]; then
    echo "Configuration file '$CONFIGURATION_FILE_PATH' does not exist."
    exit 1
fi

snapctl set device-uid="$(yq '.uid' $CONFIGURATION_FILE_PATH)"
snapctl set topic-regex="$(yq '.topic-regex' $CONFIGURATION_FILE_PATH)"
snapctl set topic-exclude="$(yq '.topic-exclude' $CONFIGURATION_FILE_PATH)"
snapctl set remote-server-ip="$(yq '.remote-server-ip' $CONFIGURATION_FILE_PATH)"
snapctl set remote-server-port="$(yq '(.remote-server-port // 2222)' $CONFIGURATION_FILE_PATH)"
snapctl set storage-base-path="$(yq '(.storage-base-path // "/var/lib/caddy-fileserver/")' $CONFIGURATION_FILE_PATH)"
snapctl set max-bag-duration="$(yq '(.max-bag-duration // 300)' $CONFIGURATION_FILE_PATH)"
snapctl set max-bag-size="$(yq '(.max-bag-size // 250000000)' $CONFIGURATION_FILE_PATH)"

echo "Configuration read."
