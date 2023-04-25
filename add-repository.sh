#!/bin/sh
# To add this repository please do:

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

${SUDO} apt-get update
${SUDO} apt-get -y install lsb-release ca-certificates curl
${SUDO} wget -O /usr/share/keyrings/smeinecke.github.io-handbrake-deb.key https://smeinecke.github.io/handbrake-deb/public.key
${SUDO} apt-add-repository "deb [signed-by=/usr/share/keyrings/smeinecke.github.io-handbrake-deb.key arch=amd64] https://smeinecke.github.io/handbrake-deb/repo $(lsb_release -sc) main"
${SUDO} apt-get update