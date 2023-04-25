#!/bin/bash
set -e

DOCKER_IMAGE_NAME="handbrake-build"
DOCKER_CONTAINER_NAME="handbrake-build-container"

if [[ $(docker ps -a | grep $DOCKER_CONTAINER_NAME) != "" ]]; then
  docker rm -f $DOCKER_CONTAINER_NAME 2>/dev/null
fi

DEB_FLAVOR="$1"
shift
HB_TAG="$1"
shift

set -x
docker build -t $DOCKER_IMAGE_NAME -f "docker/build-${DEB_FLAVOR}" docker/

docker create --name $DOCKER_CONTAINER_NAME $DOCKER_IMAGE_NAME
docker cp scripts $DOCKER_CONTAINER_NAME:/
docker start $DOCKER_CONTAINER_NAME

docker exec \
  -e DEB_FLAVOR=$DEB_FLAVOR \
  -e HB_TAG=$HB_TAG \
  -it $DOCKER_CONTAINER_NAME \
  /scripts/build.sh "$@"

docker cp $DOCKER_CONTAINER_NAME:/*.deb .