FROM debian:bookworm

ADD assets/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/90_nodoc
ADD assets/dpkg_nolocale /etc/dpkg/dpkg.cfg.d/90_nolocale
ADD assets/apt_nocache /etc/apt/apt.conf.d/90_nocache
ADD assets/apt_mindeps /etc/apt/apt.conf.d/90_mindeps

ARG DEBIAN_FRONTEND=noninteractive

# default dependencies
RUN set -e \
    && apt-get update \
    && apt-get -y install appstream autoconf automake autopoint build-essential cmake git libass-dev libbz2-dev libfontconfig1-dev libfreetype6-dev \
        libfribidi-dev libharfbuzz-dev libjansson-dev liblzma-dev libmp3lame-dev libnuma-dev libogg-dev libopus-dev libsamplerate-dev libspeex-dev \
        libtheora-dev libtool libtool-bin libturbojpeg0-dev libvorbis-dev libx264-dev libxml2-dev libvpx-dev m4 make meson nasm ninja-build patch pkg-config \
        python3 python-is-python3 tar zlib1g-dev libmp3lame-dev libnuma-dev libopus-dev libspeex-dev libvpx-dev libva-dev libdrm-dev libxml2-dev \
        libjansson-dev git debhelper-compat yasm coreutils distcc ccache wget libmfx-dev clang curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# gtk stuff
RUN set -e \
    && apt-get update \
    && apt-get -y install intltool libdbus-glib-1-dev libglib2.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk-4-dev libgudev-1.0-dev libnotify-dev libwebkit2gtk-4.0-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# set default
RUN rustup default stable

ENTRYPOINT echo hello && sleep infinity