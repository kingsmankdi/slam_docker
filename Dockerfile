FROM ubuntu:20.04

RUN set -ex \
    # Setup environment
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq -y dist-upgrade \
    && apt-get -qq -y install --no-install-recommends software-properties-common \
        locales python3 python3-lxml python3-pip \
        neofetch git make g++ gcc automake autoconf \
        # MegaSDK-REST dependencies
        libc-ares-dev libcrypto++-dev libcurl4-openssl-dev libpthread-stubs0-dev \
        zlib1g-dev libtool qt5-default libfreeimage-dev swig libboost-all-dev \
        libmagic-dev libsodium-dev libsqlite3-dev libssl-dev \
        # MirrorBot dependencies
        aria2 curl ffmpeg jq p7zip-full p7zip-rar pv \
        qbittorrent-nox tzdata xz-utils wget curl unzip

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen 
    
# Setup MirrorBot dependencies
ENV MEGA_SDK_VERSION=3.9.7
RUN git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk && cd ~/home/sdk && rm -rf .git && autoupdate -fIv && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples && make -j$(nproc --all) && cd bindings/python/ && python3 setup.py bdist_wheel && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl

# Cleanup environment
RUN apt-get -qq -y autoremove --purge \
    && apt-get -qq -y clean \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/*
    
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
    
CMD ["bash", "start.sh"]
