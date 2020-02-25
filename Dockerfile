FROM ubuntu:18.04
MAINTAINER Matt Godbolt <matt@godbolt.org>

# Enable source repositories so we can use `apt build-dep` to get all the
# build dependencies for Python 3.5+.
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && \
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt upgrade -y -q && apt update -y -q && \
    # Use python3.6 build-deps for Ubuntu 18.04.
    apt -q build-dep -y python3.6 && \
    apt -q install -y \
    wget \
    git \
    s3cmd \
    xz-utils \
    && \
    # Remove apt's lists to make the image smaller.
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root
COPY build /root/

WORKDIR /root
