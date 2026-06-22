#!/usr/bin/bash -eu

ROSBAG2_RECORDER_CONFIG_FILE="${SNAP_COMMON}/configuration/ros2-exporter-agent/rosbag2-recorder.yaml"

if [[ ! -f "${ROSBAG2_RECORDER_CONFIG_FILE}" ]]; then
  logger -t "${SNAP_NAME}" "rosbag2-recorder configuration file not found at ${ROSBAG2_RECORDER_CONFIG_FILE}."
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
