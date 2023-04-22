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

if [ -d /deps ]; then
  mv /deps/* .
  export PATH=$PWD/cmake-3.16.3-Linux-x86_64/bin:$PATH
fi

# Display tools version
cmake --version | head -n 1
chmod  +x configure

if [ "${DEB_FLAVOR}" == "jammy" ]; then
  pwd
  echo "Workaround as build via normal dpkg-buildpackage does not work on jammy"
  echo "So, build manually and simply using equivs to get deb packages"
  ./configure \
    --prefix=/usr \
    --host=x86_64-linux-gnu \
    --build=build/ \
    --debug=std \
    --enable-vce \
    --enable-fdk-aac \
    --enable-x265 \
    --disable-gtk-update-checks \
    --enable-qsv --enable-nvenc --enable-nvdec --enable-numa \
    --launch-jobs=0 --launch
  sed -i "s,_VERSION_,${HB_TAG},g" ${SCRIPTDIR}/${DEB_FLAVOR}/equivs-debian
  equivs-build ${SCRIPTDIR}/${DEB_FLAVOR}/equivs-debian
  rm -vf *dbgsym*.deb
  mv -v *.deb ../
  mv -v *.changes ../
  mv -v *.buildinfo ../
  exit 0;
fi

# create original source tar file - just for dpkg-buildpackage compatibility
git archive master | bzip2 > ../handbrake_${HB_TAG}.orig.tar.bz2
cp -vr ${SCRIPTDIR}/${DEB_FLAVOR} debian
(
  echo "handbrake (${HB_TAG}~${DEB_FLAVOR}) unstable; urgency=high"
  echo ""
  echo "  * upstream release"
  echo ""
  echo " -- HandBrake Build <handbrake-deb@github.com>  $(date '+%a, %d %b %Y %H:%M:%S %z')"
  echo ""
) > debian/changelog


DEB_BUILD_OPTIONS="noautodbgsym nostrip nocheck nodocs" dpkg-buildpackage -j$(nproc) -d -us -b -rfakeroot
cd ..
rm -vf *dbgsym*.deb
