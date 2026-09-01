# ros2-exporter-agent
The ROS 2 data exporter is recording ROS 2 data and exporting them on a server for later consultation.

## Requirement

- snapd >= 2.60.4+git1367.g558a947

## Synchronization setup

In order for the synchronization to function, a server must be setup.

### Client setup
- Generate an ssh key to access the server
- Place the ssh key in `/var/snap/ros2-exporter-agent/common/` (the synchronization daemon will be running as root)

The `/var/snap/ros2-exporter-agent/common/` content should look like:
```
drwx------  2 root root 4.0K sept. 29 16:32 .
drwx------ 14 root root 4.0K sept. 29 16:32 ..
-r--------  1 root root 1.7K sept. 29 16:29 <my_private_key>
```

- The daemon daily-rotation will move the bags to a new timestamped directory at midnight. Make sure to have properly configured the time on the machine. This can be verified with `timedatectl status`.

### Server setup
- Install Ubuntu
- Install `openssh-server`
- Copy the public key of the client in the `~/.ssh/authorized_keys`


## Configuration

Configuration is loaded from two locations (in priority order):

1. **Content sharing** (`configuration-read` interface):
   `/var/snap/ros2-exporter-agent/common/configuration/ros2-exporter-agent/`

2. **Local configuration**:
   `/var/snap/ros2-exporter-agent/common/local-configuration/`

On install, template files are placed in the local-configuration directory. Rename them to activate:
- `rclone.conf.template` -> `rclone.conf`
- `rosbag2-recorder.yaml.template` -> `rosbag2-recorder.yaml`

### `rclone.conf`

Full `rclone` configuration used by the synchronization daemon. It must define the `bagstore` remote used by `sync.sh`.

Reference: https://rclone.org/docs/

### `rosbag2-recorder.yaml`

YAML parameters passed to `rosbag2_transport recorder` as `--params-file`.

Reference: https://github.com/ros2/rosbag2/tree/rolling/rosbag2_transport
