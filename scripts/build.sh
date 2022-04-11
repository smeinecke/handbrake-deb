#!/bin/bash
set -e

if [[ -z "${HB_TAG}" ]]; then
    echo "Parameter HB_TAG missing!"
    exit 1;
fi

if [[ -z "${DEB_FLAVOR}" ]]; then
    echo "Parameter DEB_FLAVOR missing!"
    exit 1;
fi

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR="${PWD}"

git config --global advice.detachedHead false

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

echo "Checkout from tag: ${HB_TAG}"
git checkout "${HB_TAG}"
COMMIT_HASH=$(git log -n 1 --pretty=format:'%h' --abbrev=8)

# create original source tar file - just for dpkg-buildpackage compatibility
git archive master | bzip2 > ../handbrake_${HB_TAG}.orig.tar.bz2
cp -vr ${SCRIPTDIR}/debian-${DEB_FLAVOR} debian
(
  echo "handbrake (${HB_TAG}~${DEB_FLAVOR}) unstable; urgency=high"
  echo ""
  echo "  * upstream release"
  echo ""
  echo " -- HandBrake Build <handbrake-deb@github.com>  $(date '+%a, %d %b %Y %H:%M:%S %z')"
  echo ""
) > debian/changelog

bash
DEB_BUILD_OPTIONS="nocheck nodocs" dpkg-buildpackage -j$(nproc) -d -us -b
cd ..
rm -vf *dbgsym*.deb