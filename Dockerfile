FROM ubuntu:18.04
WORKDIR /updater
RUN apt-get update \
 && apt-get install -y \
    inotify-tools \
    curl \
    python3 \
    python3-distutils \
 && rm -rf /var/lib/apt/lists/* \
 && curl -O https://bootstrap.pypa.io/pip/3.6/get-pip.py \
 && python3 get-pip.py \
 && pip3 install awscli --upgrade
COPY file_placeholders/ /updater/
COPY entrypoint.sh /updater
COPY sync.sh /updater
COPY cf-ddns.sh /updater
CMD ["./entrypoint.sh"]
