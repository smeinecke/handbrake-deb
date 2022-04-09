#!/bin/bash
set -e
set -x

if [[ -z "${HB_TAG}" ]]; then
    echo "Parameter HB_TAG missing!"
fi

if [[ -z "${DEB_FLAVOR}" ]]; then
    echo "Parameter DEB_FLAVOR missing!"
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
DEB_BUILD_OPTIONS="nocheck nodocs" dpkg-buildpackage -j$(nproc) -d -us -b
cd ..
rm -vf *dbgsym*.deb
mv -v handbrake-cli_${HB_TAG}_amd64.deb handbrake-${DEB_FLAVOR}-cli_${HB_TAG}_amd64.deb
mv -v handbrake_${HB_TAG}_amd64.deb handbrake-${DEB_FLAVOR}_${HB_TAG}_amd64.deb
ls *.deb
