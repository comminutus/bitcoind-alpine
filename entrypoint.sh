#!/bin/ash

set -e

args="$@"

if [ -n "$BITCOIND_ADDITIONAL_ARGS" ]; then
    args="$args $BITCOIND_ADDITIONAL_ARGS"
fi

if [ -n "$BITCOIND_CONF" ]; then
    args="$args -conf=$BITCOIND_CONF"
fi

if [ -n "$BITCOIND_DATA_DIR" ]; then
    args="$args -datadir=$BITCOIND_DATA_DIR"
fi


old_ifs=$IFS
set -- $args
IFS=$old_ifs

echo "bitcoind" "$@"
exec "bitcoind" "$@"
