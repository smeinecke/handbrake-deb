FROM debian:bullseye

ADD assets/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/90_nodoc
ADD assets/dpkg_nolocale /etc/dpkg/dpkg.cfg.d/90_nolocale
ADD assets/apt_nocache /etc/apt/apt.conf.d/90_nocache
ADD assets/apt_mindeps /etc/apt/apt.conf.d/90_mindeps

ARG DEBIAN_FRONTEND=noninteractive

# default dependencies
RUN set -e \
    && echo 'deb [check-valid-until=no] http://archive.debian.org/debian bullseye-backports main' > /etc/apt/sources.list.d/bullseye-backports.list \
    && apt-get update \
    && apt-get -y install appstream autoconf automake autopoint build-essential cmake git libass-dev libbz2-dev libfontconfig1-dev libfreetype6-dev \
        libfribidi-dev libharfbuzz-dev libjansson-dev liblzma-dev libmp3lame-dev libnuma-dev libogg-dev libopus-dev libsamplerate-dev libspeex-dev \
        libtheora-dev libtool libtool-bin libturbojpeg0-dev libvorbis-dev libx264-dev libxml2-dev libvpx-dev m4 make nasm ninja-build patch pkg-config \
        python3 python-is-python3 tar zlib1g-dev libmp3lame-dev libnuma-dev libopus-dev libspeex-dev libvpx-dev libva-dev libdrm-dev libxml2-dev \
        libjansson-dev git debhelper-compat yasm coreutils distcc ccache wget libmfx-dev clang curl libssl-dev libcurl4-openssl-dev \
        ca-certificates \
    && apt-get -y -t bullseye-backports install meson \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# HandBrake 1.11.2+ requires autoconf 2.71; bullseye only has 2.69
RUN set -e \
    && apt-get update \
    && apt-get -y install wget ca-certificates \
    && cd /tmp \
    && wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz \
    && tar -xzf autoconf-2.71.tar.gz \
    && cd autoconf-2.71 \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/autoconf-2.71* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# gtk stuff removed (gtk4 not supported in bullseye)

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# set default
RUN cargo install cargo-c && rustup default stable

ADD bin/cargo-wrapper /root/.cargo/bin/cargo-wrapper
RUN mkdir -p /root/.cargo/bin/orig && \
    mv /root/.cargo/bin/cargo /root/.cargo/bin/orig/cargo && \
    chmod +x /root/.cargo/bin/cargo-wrapper && \
    ln -s /root/.cargo/bin/cargo-wrapper /root/.cargo/bin/cargo

ENTRYPOINT echo hello && sleep infinity
