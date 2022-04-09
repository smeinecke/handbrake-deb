#!/bin/bash
set -e
set -x

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR="${PWD}"

git config --global advice.detachedHead false

case "$(uname -i)" in
  x86_64|amd64)
    export SYSTEM_ARCH="x86_64"
    SYSTEM_PLATFORM="x64";;
  i?86)
    export SYSTEM_ARCH="i686"
    SYSTEM_PLATFORM="x86";;
  *)
    echo "Unsupported system architecture"
    exit 1;;
esac
echo "System architecture: ${SYSTEM_PLATFORM}"

case "${ARCH:-$(uname -i)}" in
  x86_64|amd64)
    TARGET_ARCH="x86_64"
    PLATFORM="x64";;
  i?86)
    TARGET_ARCH="i686"
    PLATFORM="x86";;
  *)
    echo "Unsupported target architecture"
    exit 1;;
esac
echo "Target architecture: ${PLATFORM}"

# Display tools version
cmake --version | head -n 1

# Enable ccache
export PATH="/usr/lib/ccache:${PATH}"
export CCACHE_DIR="${WORKDIR}/cache/ccache"

# Checkout handbreak
cd "${WORKDIR}"
if [[ -d HandBrake ]]; then
  cd HandBrake
  git clean -xdf
  git fetch -t
  git checkout master
  git pull --ff-only
  cd ..
else
  git clone --branch master https://github.com/HandBrake/HandBrake.git
fi

# If building from tag use a specific version of sources
cd HandBrake
if [[ -n "${HB_TAG}" ]]; then
  echo "Checkout from tag: ${HB_TAG}"
  git checkout "${HB_TAG}"
fi
COMMIT_HASH=$(git log -n 1 --pretty=format:'%h' --abbrev=8)

# create original source tar file - just for dpkg-buildpackage compatibility
git archive master | bzip2 > ../handbrake_${HB_TAG}.orig.tar.bz2
cp -vr ${SCRIPTDIR}/debian-${DEB_FLAVOR} debian

DEB_BUILD_OPTIONS="nocheck nodocs" dpkg-buildpackage -j$(nproc) -d -us -b
