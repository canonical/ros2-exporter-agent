#!/usr/bin/bash -e

ARGUMENTS=""

# $1 -> flag, $2 -> snap configuration name
function append_argument {
    VALUE="$(snapctl get $2)"
    if [[ -n "${VALUE}" ]]; then
        ARGUMENTS+="$1 $VALUE "
    fi
}

append_argument "--regex" "topic-regex"
append_argument "--exclude" "topic-exclude"
append_argument "--max-bag-duration" "max-bag-duration"
append_argument "--max-bag-size" "max-bag-size"


cd $SNAP_COMMON/data
$SNAP/ros2 bag record --all --storage mcap $ARGUMENTS
