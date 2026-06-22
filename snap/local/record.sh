#!/usr/bin/bash -eu

# Content sharing takes priority over local configuration
CONTENT_CONFIG_DIR="${SNAP_COMMON}/configuration/ros2-exporter-agent"
LOCAL_CONFIG_DIR="${SNAP_COMMON}/local-configuration"

if [ -f "${CONTENT_CONFIG_DIR}/rosbag2-recorder.yaml" ]; then
  ROSBAG2_RECORDER_CONFIG_FILE="${CONTENT_CONFIG_DIR}/rosbag2-recorder.yaml"
elif [ -f "${LOCAL_CONFIG_DIR}/rosbag2-recorder.yaml" ]; then
  ROSBAG2_RECORDER_CONFIG_FILE="${LOCAL_CONFIG_DIR}/rosbag2-recorder.yaml"
else
  logger -t "${SNAP_NAME}" "rosbag2-recorder configuration file not found."
  exit 1
fi

BAG_URI="${SNAP_COMMON}/data/rosbag2_$(date +%Y_%m_%d-%H_%M_%S)"
mkdir -p "${SNAP_COMMON}/data"

ARGUMENTS=(
  --ros-args
  --remap __node:=cos_rosbag2_recorder
  -p "storage.uri:=${BAG_URI}"
  --params-file "${ROSBAG2_RECORDER_CONFIG_FILE}"
)

logger -t "${SNAP_NAME}" "Starting rosbag2 recorder with arguments: ${ARGUMENTS[*]}"

"${SNAP}/ros2" run rosbag2_transport recorder "${ARGUMENTS[@]}"
