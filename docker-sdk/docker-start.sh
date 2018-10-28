#!/bin/sh
#
# This script will start containers that were generated with create.sh

for i in $(cat onions.txt); do
	onion="$(echo $i | cut -d':' -f2)"
	container="$(docker run -d dyne/decodeos:$onion)"
	echo "Started container $container for $onion"
done
