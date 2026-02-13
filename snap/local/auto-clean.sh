#!/usr/bin/bash -e

echo "Starting auto-clean."

mkdir -p "${SNAP_COMMON}/data"

# get the list of files older than 10 minutes
LIST_OF_FILES=$(fdfind --type file --change-older-than 10min . $SNAP_COMMON/data) # TODO make the time configurable

# remove old files
rm -f --verbose $LIST_OF_FILES

# get the list of empty directories
LIST_OF_EMPTY_DIRS=$(fdfind --type directory --type empty . $SNAP_COMMON/data)

# remove old an empty directories
rm -df --verbose $LIST_OF_EMPTY_DIRS

echo "Auto-clean done."
