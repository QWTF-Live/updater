#!/usr/bin/env bash

printenv | grep -v "no_proxy" >> /etc/environment

SHARDS=/srv/shards

# Run sync on init
source sync.sh -a

sleep 60

# Each shard writes its stats into its own homedir. The watch has to be
# attached to files that already exist, so seed one per shard first - FTE only
# creates data/ when it has something to put there.
for dir in "$SHARDS"/*/fortress/data; do
  [ -d "$dir" ] || continue
  touch "$dir/upload_ready"
done

# Run when fosv makes upload_ready file
inotifywait -m "$SHARDS"/*/fortress/data/upload_ready -e modify --format '%w' |
  while read -r file; do
    if [[ $(basename "${file}") == "upload_ready" ]]; then
      echo PING $file
      ./sync.sh -s -p -m -d
    fi
  done
