#!/usr/bin/env bash
set -e
set -o pipefail

url_encode() {
    local encoded=""
    local char=""
    for (( i = 0; i < ${#1}; i++ )); do
        char="${1:$i:1}"
        if [[ "$char" =~ [a-zA-Z0-9.~_-] ]]; then
            encoded+="$char"
        else
            printf -v hex '%02X' "'$char"
            encoded+="%$hex"
        fi
    done
    echo "$encoded"
}

sync_stats() {
  echo sync stats

  for subdir in /updater/stats/*; do
    if [[ -d "$subdir" ]]; then
      for file in "$subdir"/*.json; do
        [ -e "$file" ] || continue
        filename=$(basename "$file")
        subdir_name=$(basename "$subdir")

        echo Posting: $file
        curl -X POST -d @$file "logs.qwtf.live/api/upload_stats" && mv $file $file.done
      done
    fi
  done
  find /updater/stats -type f -mtime +20 -name '*.done' -delete 2> /dev/null
}

sync_demos() {
  echo sync demos
  if [ -n "${AWS_SECRET_ACCESS_KEY}" ] && [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${FO_REGION}" ]; then
    if [ -n "${S3_DEMO_URI}" ]; then
      /usr/local/bin/aws s3 sync --exclude 'duel/*' \
        /updater/demos/ "${S3_DEMO_URI}/${FO_REGION}/" \
        && find /updater/demos/ \( -name "*.mvd" -o -name "*.gz" \) -type f -mtime +6 -delete 2>/dev/null
    fi
  fi
}

sync_progs() {
  echo sync progs
  /usr/local/bin/aws s3 sync \
    --no-sign-request \
    --exact-timestamps \
    --cli-read-timeout 600 \
    --cli-connect-timeout 600 \
    s3://qwtflive-dats \
    /updater/dats/
}

sync_maps() {
  echo sync maps
  /usr/local/bin/aws s3 sync \
    --size-only \
    --no-sign-request \
    --cli-read-timeout 600 \
    --cli-connect-timeout 600 \
    s3://fortressone-package \
    /updater/map-repo/fortress/maps/
}

sync_dns() {
  echo sync dns
  ./cf-ddns.sh
}

echo Start $(date) [$@]
aws configure set s3.max_concurrent_requests 1
while getopts "psmda" option; do
  case $option in
    s)
      sync_stats;;
    p)
      sync_progs;;
    m)
      sync_maps;;
    d)
      sync_demos;;
    a)
      sync_dns;
      sync_progs;
      sync_stats;
      sync_maps;
      sync_demos;;
  esac
done
echo Finish $(date)
