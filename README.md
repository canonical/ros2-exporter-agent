# ros2-exporter-agent
The ROS 2 data exporter is recording ROS 2 data and exporting them on a server for later consultation.

## Requirement

- snapd >= 2.60.4+git1367.g558a947

## Synchronization setup

In order for the synchronization to function, a server must be setup.

### Client setup
- Generate an ssh key to access the server
- Place the ssh key as well as the `config` file in `/root/snap/ros2-exporter-agent/common/.ssh` (the syncronization daemon will be running as root)

The `/root/snap/ros2-exporter-agent/common/.ssh` content should look like:
```
drwx------  2 root root 4.0K sept. 29 16:32 .
drwx------ 14 root root 4.0K sept. 29 16:32 ..
-rw-------  1 root root   85 sept. 29 16:32 config
-rw-r--r--  1 root root  444 sept. 21 14:48 known_hosts
-r--------  1 root root 1.7K sept. 29 16:29 <my_private_key>
```

The `config` file should look like:
```
Host storage-server
    User <server_user>
    HostName <server_hostname>
    IdentityFile /root/snap/ros2-exporter-agent/common/.ssh/<my_private_key>
    UserKnownHostsFile /root/snap/ros2-exporter-agent/common/.ssh/known_hosts
```

If the known_hosts is not created, we can create it with:
```
sudo ssh-keyscan -H <server_hostanme> >> /root/snap/ros2-exporter-agent/common/.ssh/known_hosts
```

### Server setup
- Install Ubuntu
- Install `openssh-server`
- Copy the public key of the client in the `~/.ssh/authorized_keys`


## Snap parameters
- `storage-server`, url of the synchronization server | unset by default
- `topic-regex`, topic regex to record for the bag recording, override the default "all" behaviour | unset by default
- `topic-exclude`, topic regex to exclude for the bag recording, works on top of "all" and `topic-regex`. | unset by default
- `max-bag-duration`, maximum bag duration in seconds before the bag file is split | default to: 300
- `max-bag-size`, maximum bag size in bytes before the bag file is split | default to: 250000000

