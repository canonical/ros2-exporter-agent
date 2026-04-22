#!/usr/bin/bash -eu

ROSBAG2_RECORDER_CONFIGURATION="$(snapctl get --view :confdb-configuration rosbag2-recorder)"

if [[ -z "${ROSBAG2_RECORDER_CONFIGURATION}" ]]; then
  logger -t "${SNAP_NAME}" "rosbag2-recorder configuration is empty, cannot start the recorder"
  exit 1
fi


BAG_URI="${SNAP_COMMON}/data/rosbag2_$(date +%Y_%m_%d-%H_%M_%S)"
mkdir -p "${SNAP_COMMON}/data"

. "${SNAP}/usr/bin/write-tmp-file.sh" "${ROSBAG2_RECORDER_CONFIGURATION}" ROSBAG2_RECORDER_CONFIG_FILE

ARGUMENTS=(
  --ros-args
  --remap __node:=cos_rosbag2_recorder
  -p "storage.uri:=${BAG_URI}"
  --params-file "${ROSBAG2_RECORDER_CONFIG_FILE}"
)

logger -t "${SNAP_NAME}" "Starting rosbag2 recorder with arguments: ${ARGUMENTS[*]}"

"${SNAP}/ros2" run rosbag2_transport recorder "${ARGUMENTS[@]}"
