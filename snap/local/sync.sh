#!/usr/bin/bash -eu

RCLONE_CONFIG_FILE="${SNAP_COMMON}/configuration/ros2-exporter-agent/rclone.conf"

if [[ ! -f "${RCLONE_CONFIG_FILE}" ]]; then
  logger -t "${SNAP_NAME}" "Rclone configuration file not found at ${RCLONE_CONFIG_FILE}."
  exit 1
fi

logger -t "${SNAP_NAME}" "Starting sync."

# We copy the private key so that we can modify the permissions. 
# The content-sharing interfce sets the permissions to 644 
# which are too loose for the key to be used safely. We cannot 
# modify the permission before because the content sharing snap
# imposes it's own permission and this snap has read-only access.
# The alternative would be to give this snap write access. 

if [ -f "${SNAP_COMMON}/rob-cos-shared-data/device_rsa_key" ]; then
    cp "${SNAP_COMMON}/rob-cos-shared-data/device_rsa_key" "${SNAP_USER_COMMON}/"
    chmod 600 "${SNAP_USER_COMMON}/device_rsa_key"
else
    >&2 echo "could not find device_rsa_key. If you need, make sure it's available in the rob-cos-data-sharing snap."
fi

echo "Starting to copy the files with Rclone."

mkdir -p "${SNAP_COMMON}/data"
rclone copy --config "${RCLONE_CONFIG_FILE}" \
  --min-size 1b "${SNAP_COMMON}/data/" "bagstore:/" 2>&1 || true
