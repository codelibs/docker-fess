#!/bin/bash

set -e

# Add fess as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- fess "$@"
fi

# Drop root privileges if we are running fess
# allow the container to be started with `--user`
if [ "$1" = 'fess' -a "$(id -u)" = '0' ]; then
	set -- gosu fess "$@"
	#exec gosu fess "$BASH_SOURCE" "$@"
fi

# As argument is not related to fess,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
