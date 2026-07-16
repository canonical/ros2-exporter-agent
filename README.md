# ros2-exporter-agent

`ros2-exporter-agent` is a general-purpose utility snap that records ROS 2 data
into rosbags and automatically uploads them to a remote storage backend for
later consultation.

If you have an **S3 bucket** or a simple **SFTP/SSH server**,
point the snap at it and your robots will record and store their bags
automatically.
Uploads are powered by [rclone](https://rclone.org/),
so any rclone-supported backend works.
It also integrates with
the [Canonical Observability Stack (COS)](https://canonical-robotics.readthedocs-hosted.com/en/latest/explanations/observability/what-is-cos-for-robotics/).

## Features

- **Recorder** — records ROS 2 topics to rosbag2 (mcap), with topic selection by
  regex and configurable bag size/duration rotation.
- **Synchronization** — periodically uploads recorded bags to remote storage via
  rclone (S3, SFTP/SSH, and any other rclone backend).
- **Daily rotation** — moves bags into a fresh timestamped directory at midnight.
- **Auto-clean** — deletes already-synced local bags to protect disk usage.
- **Flexible configuration** — loaded from a local file or shared over the
  content interface for centralized/fleet management.
- **Broad ROS 2 support** — bundles a large set of ROS 2 message definitions and
  DDS vendors so bags of virtually any message type can be recorded.

## Requirement

- snapd >= 2.60.4+git1367.g558a947

## Configuration

Configuration is loaded from two locations (in priority order):

1. **Content-sharing** (`configuration-read` interface):
   `/var/snap/ros2-exporter-agent/common/configuration/ros2-exporter-agent/`

2. **Local configuration**:
   `/var/snap/ros2-exporter-agent/common/local-configuration/`

On install, template files are placed in the local-configuration directory.
Rename them (remove the `.template` suffix) to activate:
- `rclone.conf.template` -> `rclone.conf`
- `rosbag2-recorder.yaml.template` -> `rosbag2-recorder.yaml`

A reference content-sharing implementation is available: [rob-cos-demo-configuration](https://github.com/canonical/rob-cos-demo-configuration)

### `rclone.conf`

Full [`rclone`](https://rclone.org/docs/)
configuration used by the synchronization daemon.
It must define a `bagstore` remote,
which is the destination bags are uploaded to.
Any rclone backend can be used.

### `rosbag2-recorder.yaml`

[YAML parameters](https://github.com/ros2/rosbag2/tree/rolling/rosbag2_transport 
) passed to `rosbag2_transport recorder` as `--params-file`.

Example configuration:

```yaml
ros2_exporter_agent_rosbag2_recorder:
  ros__parameters:
    record:
      regex: '.*'
    storage:
      storage_id: 'mcap'
      max_bagfile_duration: 1230
      max_bagfile_size: 10000000000
```

The daily-rotation daemon moves the bags to a new timestamped directory at
midnight. Make sure the time is properly configured on the machine.
This can be verified with `timedatectl status`.

## Storage setup

Below are two common ways to configure the `bagstore` remote in `rclone.conf`.

### SFTP / SSH server

Any machine running an SSH server can be used as the storage backend.

**Server setup**
- Install Ubuntu (or any Linux) and `openssh-server`.
- Copy the client's public key into `~/.ssh/authorized_keys`.

**Client setup**
- Generate an SSH key to access the server.
- Place the private key in `/var/snap/ros2-exporter-agent/common/` (the
  synchronization daemon runs as root).

The `/var/snap/ros2-exporter-agent/common/` content should look like:
```
drwx------  2 root root 4.0K sept. 29 16:32 .
drwx------ 14 root root 4.0K sept. 29 16:32 ..
-r--------  1 root root 1.7K sept. 29 16:29 <my_private_key>
```

Then configure the `bagstore` remote to use SFTP:

```ini
[fileserver]
type = sftp
host = your.fileserver.example.com
user = root
port = 22
key_file = /var/snap/ros2-exporter-agent/common/<my_private_key>

[bagstore]
type = alias
remote = fileserver:/var/lib/robot-bags/robot-123
```

Reference: https://rclone.org/sftp/

### Amazon S3 (or S3-compatible)

Create a bucket and credentials with your provider, then configure the
`bagstore` remote to point at the bucket (and optionally a per-robot prefix):

```ini
[s3]
type = s3
provider = AWS
access_key_id = YOUR_ACCESS_KEY
secret_access_key = YOUR_SECRET_KEY
region = eu-west-1

[bagstore]
type = alias
remote = s3:my-bucket/robot-123
```

See the rclone S3 docs for other providers (MinIO, Ceph, Wasabi, etc.):
https://rclone.org/s3/

## COS integration (optional)

For fleet deployments, `ros2-exporter-agent` can receive its configuration and
credentials over the content-sharing interfaces instead of local files:

- `configuration-read` provides `rclone.conf` and `rosbag2-recorder.yaml` from a
  central configuration snap (takes priority over local configuration).
- `rob-cos-common-read` provides a shared `device_rsa_key` used to authenticate
  against the storage server.

This lets you manage recording and upload configuration centrally across a fleet
via the Canonical Observability Stack (COS) for devices.
