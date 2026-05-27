#!/usr/bin/bash -e

echo "Reading configuration yaml from configuration snap."

snapctl set config-ready=false

RCLONE_CONFIGURATION_FILE_PATH=$SNAP_COMMON/configuration/ros2-exporter-agent/rclone.conf
ROSBAG2_RECORDER_CONFIGURATION_FILE_PATH=$SNAP_COMMON/configuration/ros2-exporter-agent/rosbag2-recorder.yaml

if [ -f "$RCLONE_CONFIGURATION_FILE_PATH" ]; then
    snapctl set rclone-conf="$(<"$RCLONE_CONFIGURATION_FILE_PATH")"
    echo "Loaded rclone.conf into rclone-conf."
fi

if [ -f "$ROSBAG2_RECORDER_CONFIGURATION_FILE_PATH" ]; then
    snapctl set rosbag2-recorder="$(<"$ROSBAG2_RECORDER_CONFIGURATION_FILE_PATH")"
    echo "Loaded rosbag2-recorder.yaml into rosbag2-recorder."
fi

snapctl set config-ready=true

echo "Configuration read."
