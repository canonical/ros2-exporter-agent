#!/usr/bin/bash -eu

ROSBAG2_RECORDER_CONFIG="$(snapctl get rosbag2-recorder)"

if [[ -z "${ROSBAG2_RECORDER_CONFIG}" ]]; then
  logger -t "${SNAP_NAME}" "rosbag2-recorder configuration is not set."
  exit 1
fi

BAG_URI="${SNAP_COMMON}/data/rosbag2_$(date +%Y_%m_%d-%H_%M_%S)"
mkdir -p "${SNAP_COMMON}/data"

ROSBAG2_RECORDER_CONFIG_FILE="$(mktemp)"
trap 'rm -f "${ROSBAG2_RECORDER_CONFIG_FILE}"' EXIT
printf '%s\n' "${ROSBAG2_RECORDER_CONFIG}" > "${ROSBAG2_RECORDER_CONFIG_FILE}"

ARGUMENTS=(
  --ros-args
  --remap __node:=cos_rosbag2_recorder
  -p "storage.uri:=${BAG_URI}"
  --params-file "${ROSBAG2_RECORDER_CONFIG_FILE}"
)

logger -t "${SNAP_NAME}" "Starting rosbag2 recorder with arguments: ${ARGUMENTS[*]}"

"${SNAP}/ros2" run rosbag2_transport recorder "${ARGUMENTS[@]}"
