#!/usr/bin/bash -e

mkdir -p "${SNAP_COMMON}/data"
BAG_URI="${SNAP_COMMON}/data/rosbag2_$(date +%Y_%m_%d-%H_%M_%S)"

ARGUMENTS="--ros-args --remap __node:=cos_rosbag2_recorder -p storage.uri:=\"${BAG_URI}\""

if [ -f "${SNAP_COMMON}/configuration/rosbag2-recorder.yaml" ]; then
    ARGUMENTS="${ARGUMENTS} --params-file ${SNAP_COMMON}/configuration/rosbag2-recorder.yaml"
fi

${SNAP}/ros2 run rosbag2_transport recorder ${ARGUMENTS}
