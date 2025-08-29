# ros2-exporter-agent

The ROS 2 data exporter records ROS 2 rosbags and
exports them on a server for later consultation.

## Synchronization setup

In order for the synchronization to function,
an S3 endpoint must be available.

### Client setup

- Generate an `access-key-id`/`secret-access-key` pair
  to access the server
- Create a bucket accessible with the credentials
- Set those in a file in `${SNAP_COMMON}/configuration/ros2-data-exporter.yaml`
- The daemon `daily-rotation` will move the bags to
  a new timestamped directory at midnight.
  Make sure to have properly configured the time on the machine.
  This can be verified with `timedatectl status`.

## Snap parameters

- `topic-regex`, topic regex to record for the bag recording, override the default "all" behaviour | unset by default
- `topic-exclude`, topic regex to exclude for the bag recording, works on top of "all" and `topic-regex`. | unset by default
- `max-bag-duration`, maximum bag duration in seconds before the bag file is split | default to: 300
- `max-bag-size`, maximum bag size in bytes before the bag file is split | default to: 250000000
