#!/bin/bash
apt-get -qy update && apt-get install -qy \
    man \
    vim \
    nano \
    htop \
    curl \
    wget \
    rsync \
    ca-certificates \
    git \
    zip \
    procps \
    ssh \
    gettext-base \
    transmission-cli \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

# To avoid error on next step
mkdir -p /workspace
# If /workspace is not empty, save it into /workspace.tgz
if [ $( find /workspace -maxdepth 0 -empty | wc -l ) -lt 1 ]; then
	echo "Creating /workspace.tgz to preserve /workspace"
	tar -czf /workspace.tgz /workspace && \
	rm /workspace -R && \
	mkdir /workspace
else
	echo "No need to preserve /workspace"
fi

