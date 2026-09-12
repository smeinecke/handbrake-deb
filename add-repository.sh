#!/bin/sh
# To add this repository please do:

set -eu

if [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

if [ -r /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    DISTRO_ID="${ID:-}"
    CODENAME="${VERSION_CODENAME:-}"
else
    DISTRO_ID=
    CODENAME=
fi

if [ -z "${DISTRO_ID}" ] || [ -z "${CODENAME}" ]; then
    echo "Unable to detect distro codename from /etc/os-release."
    echo "This repository supports Debian (bullseye, bookworm, trixie) and Ubuntu (focal, jammy, noble, resolute)."
    exit 1
fi

case "${DISTRO_ID}:${CODENAME}" in
    debian:bullseye|debian:bookworm|debian:trixie|ubuntu:focal|ubuntu:jammy|ubuntu:noble|ubuntu:resolute)
        ;;
    *)
        echo "Unsupported distribution: ${DISTRO_ID}:${CODENAME}"
        echo "Supported releases: debian:{bullseye,bookworm,trixie} ubuntu:{focal,jammy,noble,resolute}"
        exit 1
        ;;
esac

KEYRING=/usr/share/keyrings/smeinecke.github.io-handbrake-deb.key
SOURCE_NAME=smeinecke-handbrake-deb

${SUDO} apt-get update
${SUDO} apt-get -y install ca-certificates wget
${SUDO} wget -O "${KEYRING}" https://smeinecke.github.io/handbrake-deb/public.key

if [ -f "/etc/apt/sources.list.d/${DISTRO_ID}.sources" ]; then
    ${SUDO} rm -f "/etc/apt/sources.list.d/${SOURCE_NAME}.list"
    ${SUDO} tee "/etc/apt/sources.list.d/${SOURCE_NAME}.sources" >/dev/null <<EOF
Types: deb
URIs: https://smeinecke.github.io/handbrake-deb/repo
Suites: ${CODENAME}
Components: main
Signed-By: ${KEYRING}
Architectures: amd64
EOF
else
    ${SUDO} rm -f "/etc/apt/sources.list.d/${SOURCE_NAME}.sources"
    ${SUDO} tee "/etc/apt/sources.list.d/${SOURCE_NAME}.list" >/dev/null <<EOF
deb [signed-by=${KEYRING} arch=amd64] https://smeinecke.github.io/handbrake-deb/repo ${CODENAME} main
EOF
fi

${SUDO} apt-get update
