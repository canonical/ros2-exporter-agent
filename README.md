# ros2-exporter-agent
The ROS 2 data exporter is recording ROS 2 data and exporting them on a server for later consultation.

## Requirement

- snapd >= 2.60.4+git1367.g558a947
- Confdb experimental feature enabled in snapd: `sudo snap set system experimental.confdb=true`

## Synchronization setup

In order for the synchronization to function, a server must be setup.

### Client setup
- Generate an ssh key to access the server
- Place the ssh key in `/root/snap/ros2-exporter-agent/common/.ssh` (the synchronization daemon will be running as root)

The `/root/snap/ros2-exporter-agent/common/` content should look like:
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


## Confdb configuration
- `rclone`, full `rclone` configuration content read from the `ros2-exporter-agent/configuration` confdb view. It must define the `bagstore` remote used by `sync.sh`.
- `rosbag2-recorder`, YAML content read from the same confdb view and passed to `rosbag2_transport recorder` as `--params-file`.
