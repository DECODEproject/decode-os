#!/bin/sh
#
# This script will stop and delete the created containers and images.

containers="$(docker container ls | awk '/dyne\/decodeos:.*\.onion/ {print $1}')"

echo "$containers" | xargs docker stop
echo "$containers" | xargs docker rm

images="$(docker images | awk '/dyne\/decodeos:.*\.onion/ {print $3}')"

echo "$images" | xargs docker rmi
