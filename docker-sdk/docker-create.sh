#!/bin/sh
#
# This script will run the keygen script for a requested amount of times.
# It takes an optional integer parameter - amount - for the amount of dockers.
# Otherwise it will default to 5.

usage() {
	echo "$(basename $0) [number]"
	exit 1
}

[ -z "$1" ] && AMOUNT=5

case "$1" in
	*[!0-9]*)
		usage
		;;
	*)
		AMOUNT="$1"
		;;
esac

rm -f onions.txt

for i in $(seq 1 $AMOUNT); do
	./keygen
done
