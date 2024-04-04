!#/usr/bin/bash

docker build --tag=updater .
docker tag updater qwtflive/updater:latest
docker push qwtflive/updater:latest
