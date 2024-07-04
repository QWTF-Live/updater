 #!/bin/bash

curl -X POST -d @$1 "logs.qwtf.live/api/upload_stats"

