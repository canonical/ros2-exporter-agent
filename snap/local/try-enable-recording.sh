#!/usr/bin/bash -e

RCLONE_CONFIG_FILE="${SNAP_COMMON}/configuration/ros2-exporter-agent/rclone.conf"
ROSBAG2_RECORDER_CONFIG_FILE="${SNAP_COMMON}/configuration/ros2-exporter-agent/rosbag2-recorder.yaml"

if snapctl services "${SNAP_NAME}.auto-clean" | grep -q inactive; then
	snapctl start --enable "${SNAP_NAME}.auto-clean" 2>&1 || true
fi

if [ ! -f "${RCLONE_CONFIG_FILE}" ]; then
	logger -t "${SNAP_NAME}" "Cannot start recorder yet, rclone configuration not found at ${RCLONE_CONFIG_FILE}"
	exit 0
fi

if [ ! -f "${ROSBAG2_RECORDER_CONFIG_FILE}" ]; then
	logger -t "${SNAP_NAME}" "Cannot start recorder yet, rosbag2-recorder configuration not found at ${ROSBAG2_RECORDER_CONFIG_FILE}"
	exit 0
fi

if ! snapctl is-connected rob-cos-common-read; then
	logger -t "${SNAP_NAME}" "rob-cos-common-read is not connected."
fi

## if auto-clean started correctly we can start recording
if snapctl services "${SNAP_NAME}.auto-clean" | grep -q enabled; then
	if snapctl services "${SNAP_NAME}.recorder" | grep -q inactive; then
		snapctl start --enable "${SNAP_NAME}.recorder" 2>&1 || true
	fi
else
	echo "auto-clean service not enabled - could not start recorder to avoid filling up disk"
	exit 1
fi

if snapctl services "${SNAP_NAME}.synchronization"| grep -q inactive; then
	snapctl start --enable "${SNAP_NAME}.synchronization" 2>&1 || true
fi

if snapctl services "${SNAP_NAME}.daily-rotation" | grep -q inactive; then
	snapctl start --enable "${SNAP_NAME}.daily-rotation" 2>&1 || true
fi
