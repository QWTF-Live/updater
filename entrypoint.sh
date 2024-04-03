#!/usr/bin/env bash

printenv | grep -v "no_proxy" >> /etc/environment

# Run sync on init
source sync.sh -a

# Run when fosv makes upload_ready file
inotifywait -m /updater/stats/ --recursive --event create --format '%w%f' |
  while read -r file; do
    if [[ $(basename "${file}") == "upload_ready" ]]; then
      rm "${file}"
      echo "Deleted upload_ready file: ${file}"
      source sync.sh -s -p
    fi
  done
