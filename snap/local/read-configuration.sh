#!/usr/bin/sh -e

MSG="Reading configuration from configuration snap."
echo "${MSG}"
logger -t ${SNAP_NAME} "${MSG}"

CONFIGURATION_PATH="${SNAP_COMMON}/configuration"
CONFIGURATION_FILE_PATH="${CONFIGURATION_PATH}/ros2-data-exporter.yaml"

if [ ! -f "${CONFIGURATION_FILE_PATH}" ]; then
  MSG="Configuration file '${CONFIGURATION_FILE_PATH}' does not exist."
  echo "${MSG}"
  logger -t ${SNAP_NAME} "${MSG}"
  exit 1
fi

# If the buck is set, use that. Otherwise, use the device uid
# DUID="$(snapctl get device-uid)" snapctl set bucket="$(yq '(.bucket // "${DUID}") | envsubst' ${CONFIGURATION_FILE_PATH})"

snapctl set access-key-id="$(yq '.access-key-id' ${CONFIGURATION_FILE_PATH})"
snapctl set bucket="$(yq '.bucket' ${CONFIGURATION_FILE_PATH})"
snapctl set device-uid="$(yq '.uid' ${CONFIGURATION_FILE_PATH})"
snapctl set remote-server-ip="$(yq '.remote-server-ip' ${CONFIGURATION_FILE_PATH})"
snapctl set secret-access-key="$(yq '.secret-access-key' ${CONFIGURATION_FILE_PATH})"

snapctl set max-bag-duration="$(yq '(.max-bag-duration // 300)' ${CONFIGURATION_FILE_PATH})"
snapctl set max-bag-size="$(yq '(.max-bag-size // 250000000)' ${CONFIGURATION_FILE_PATH})"
snapctl set topic-exclude="$(yq '.topic-exclude' ${CONFIGURATION_FILE_PATH})"
snapctl set topic-regex="$(yq '.topic-regex' ${CONFIGURATION_FILE_PATH})"

# Create rclone's configuration file
mkdir -p "${SNAP_DATA}/.config/rclone"
cat > "${SNAP_DATA}/.config/rclone/rclone.conf" <<EOF
[robcos]
type = s3
provider = Ceph
endpoint = $(snapctl get remote-server-ip)
env_auth = true
EOF
