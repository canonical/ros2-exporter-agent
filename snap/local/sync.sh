#!/usr/bin/sh -e

RCLONE_CONF="${SNAP_DATA}/.config/rclone/rclone.conf"

if [ ! -f "${RCLONE_CONF}" ]; then
  MSG="The exporter is not fully configured. Cannot sync."
  echo "${MSG}"
  logger -t ${SNAP_NAME} "${MSG}"
  exit 1
fi

if ! $(${SNAP}/usr/bin/check-bucket); then
  MSG="Could not find bucket '$(snapctl get bucket)'."
  echo "${MSG}"
  logger -t ${SNAP_NAME} "${MSG}"
  exit 1
fi

# If there are 2 rosbag files or more
# sync them except the most recent one
if [ $(ls "${SNAP_COMMON}/data/" | wc -l) -ge 2 ]; then
  MOST_RECENT_FOLDER=$(ls -t "${SNAP_COMMON}/data/" | head -n 1)

  RCLONE_CONFIG_ROBCOS_ACCESS_KEY_ID="$(snapctl get access-key-id)" \
  RCLONE_CONFIG_ROBCOS_SECRET_ACCESS_KEY="$(snapctl get secret-access-key)" \
  rclone move "${SNAP_COMMON}/data/" "robcos:$(snapctl get bucket)" \
    --exclude "${MOST_RECENT_FOLDER}**" --delete-empty-src-dirs \
    --s3-no-check-bucket \
    --config "${RCLONE_CONF}" 2>&1 || true
fi

# @todo See where and how to sync the last file.
# if [ ! -z "${MOST_RECENT_FOLDER}" ]; then
#   rclone copyto ${MOST_RECENT_FOLDER} \
#     --config "${CONFIGURATION_FILE_RCLONE}" 2>&1 || true
# fi
