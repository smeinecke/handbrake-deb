#!/bin/sh
# To add this repository please do:

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

KEYRING=/usr/share/keyrings/smeinecke.github.io-handbrake-deb.key
SOURCE_NAME=smeinecke-handbrake-deb

${SUDO} apt-get update
${SUDO} apt-get -y install lsb-release ca-certificates wget
${SUDO} wget -O "${KEYRING}" https://smeinecke.github.io/handbrake-deb/public.key

CODENAME=$(lsb_release -sc)
VENDOR=$(lsb_release -si | tr '[:upper:]' '[:lower:]')

if [ -f "/etc/apt/sources.list.d/${VENDOR}.sources" ]; then
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
