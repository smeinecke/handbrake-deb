FROM ubuntu:noble

ADD assets/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/90_nodoc
ADD assets/dpkg_nolocale /etc/dpkg/dpkg.cfg.d/90_nolocale

ARG DEBIAN_FRONTEND=noninteractive

RUN set -e \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# default dependencies
RUN set -e \
    && apt-get update \
    && apt-get -y install \
        autoconf automake autopoint appstream build-essential cmake git libass-dev libbz2-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev \
        libharfbuzz-dev libjansson-dev liblzma-dev libmp3lame-dev libnuma-dev libogg-dev libopus-dev libsamplerate-dev libspeex-dev libtheora-dev \
        libtool libtool-bin libturbojpeg0-dev libvorbis-dev libx264-dev libxml2-dev libvpx-dev libmfx-dev zlib1g-dev libva-dev libdrm-dev libssl-dev \
        m4 make meson nasm ninja-build patch pkg-config tar clang debhelper-compat yasm distcc wget python3 python-is-python3 libvpl-dev libavcodec-dev \
        libavfilter-dev libavformat-dev libavutil-dev libbluray-dev libdvdnav-dev libffmpeg-nvenc-dev libmpeg2-4-dev libswresample-dev libswscale-dev \
        fakeroot dpkg-dev equivs ccache curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# gtk stuff
RUN set -e \
    && apt-get update \
    && apt-get -y install gstreamer1.0-libav intltool libdbus-glib-1-dev libglib2.0-dev libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good gstreamer1.0-libav libgtk-4-dev libgudev-1.0-dev libnotify-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

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