#!/bin/sh -e

# Set max concurrency to match pm.max_children. Default to 4
if [ -z "$NUM_THREADS" ]; then
    sed -i'' "s/%MAX_CHILDREN/4/g" /usr/local/etc/php-fpm.d/www.conf
else
    sed -i'' "s/%MAX_CHILDREN/${NUM_THREADS}/g" /usr/local/etc/php-fpm.d/www.conf
fi

if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"