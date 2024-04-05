#!/usr/bin/env bash

printenv | grep -v "no_proxy" >> /etc/environment

# Run sync on init
source sync.sh -a

sleep 60

find /updater/stats/ -mindepth 1 -type d | xargs -i touch {}/upload_ready

# Run when fosv makes upload_ready file
inotifywait -m /updater/stats/*/upload_ready -e modify --format '%w' |
  while read -r file; do
    if [[ $(basename "${file}") == "upload_ready" ]]; then
      echo PING $file
      ./sync.sh -s -p
    fi
  done
