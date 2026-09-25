#!/bin/bash
set -euo pipefail

# Build with BuildKit via buildx (the legacy `docker build` builder is
# deprecated), then tag, load and push in a single step.
docker buildx build \
  --tag qwtflive/updater:latest \
  --load \
  --push \
  .

# The server image embeds this one with COPY --from, so it is a version behind
# the moment this finishes. Rebuilding it is deliberately a separate step -
# this script has no business building another repo - but forgetting is exactly
# how a stale updater gets baked into an image and only surfaces on a deployed
# host. qwtfsv's build now refuses outright if it finds one.
cat >&2 <<'NOTE'

Pushed qwtflive/updater:latest.
qwtflive/fortressone embeds this image; rebuild it so the change reaches a host:

    cd ../qwtfsv && ./build_and_push.sh
NOTE
