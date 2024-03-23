Build updater:

```
docker build --tag=updater .
```


Run updater:

```sh
docker run updater
```


Stop updater:

```sh
docker container ls
docker container stop <hash>
```


Deploy updater:

```sh
docker tag updater qwtflive/updater:latest
docker push qwtflive/updater:latest
```

Environment variables:

```
AWS_SECRET_ACCESS_KEY
AWS_ACCESS_KEY_ID
S3_DEMO_URI
S3_STATS_URI
FO_STATS_FILES_ADDRESS
FO_REGION
```


Scratch:

```
no_players=$(qstat -qws sydney.fortressone.org | awk 'NR>1 {print $2;}')
[[ $no_players =~ ^0/ ]] && echo match
