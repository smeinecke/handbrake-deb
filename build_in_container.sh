#!/bin/bash
set -e

DOCKER_IMAGE_NAME="handbrake-build"
DOCKER_CONTAINER_NAME="handbrake-build-container"

if docker container inspect "$DOCKER_CONTAINER_NAME" >/dev/null 2>&1; then
  docker rm -f "$DOCKER_CONTAINER_NAME" 2>/dev/null || true
fi

if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
  echo "Usage: $0 <flavor> <handbrake-tag> [extra-build-args]"
  echo "Example: $0 bookworm 1.10.2"
  exit 1
fi

DEB_FLAVOR="$1"
shift
HB_TAG="$1"
shift

if [ ! -f "docker/build-${DEB_FLAVOR}.Dockerfile" ]; then
  echo "No Dockerfile for flavor '${DEB_FLAVOR}'"
  exit 1
fi

TTY_FLAG=
if [ -t 0 ]; then
  TTY_FLAG="-t"
fi

set -x
docker build -t "$DOCKER_IMAGE_NAME" -f "docker/build-${DEB_FLAVOR}.Dockerfile" docker/

docker create --name "$DOCKER_CONTAINER_NAME" "$DOCKER_IMAGE_NAME"
docker cp scripts "$DOCKER_CONTAINER_NAME":/
docker start "$DOCKER_CONTAINER_NAME"

docker exec \
  -e "DEB_FLAVOR=$DEB_FLAVOR" \
  -e "HB_TAG=$HB_TAG" \
  -i ${TTY_FLAG} "$DOCKER_CONTAINER_NAME" \
  /scripts/build.sh "$@"

# docker cp does not expand container-side globs, so list and copy each .deb.
rm -f ./*.deb
for pkg in $(docker exec "$DOCKER_CONTAINER_NAME" sh -c 'ls /*.deb 2>/dev/null'); do
  docker cp "$DOCKER_CONTAINER_NAME:${pkg}" .
done