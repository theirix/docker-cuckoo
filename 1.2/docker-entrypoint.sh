#!/bin/sh

set -e

# Add cuckoo as command if needed
if [ "${1:0:1}" = '-' ]; then
	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo/

	set -- python cuckoo.py "$@"
fi

# Drop root privileges if we are running cuckoo-daemon
if [ "$1" = 'daemon' -a "$(id -u)" = '0' ]; then
	shift
	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo

	set -- gosu cuckoo /sbin/tini -- python cuckoo.py "$@"

elif [ "$1" = 'submit' -a "$(id -u)" = '0' ]; then
	shift
	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo/utils

	set -- gosu cuckoo /sbin/tini -- python submit.py "$@"

elif [ "$1" = 'process' -a "$(id -u)" = '0' ]; then
	shift
	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo/utils

	set -- gosu cuckoo /sbin/tini -- python process.py "$@"

elif [ "$1" = 'api' -a "$(id -u)" = '0' ]; then

	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo/utils

	echo "waiting for postgres to become available"
	# while ! nc -z $POSTGRES_PORT_5432_TCP_ADDR $POSTGRES_PORT_5432_TCP_PORT
	while ! nc -z postgres 5432
	do
	  echo "$(date) - still trying"
	  sleep 1
	done
	echo "$(date) - connected successfully"
	
	set -- gosu cuckoo /sbin/tini -- python api.py --host 0.0.0.0 --port 1337

elif [ "$1" = 'web' -a "$(id -u)" = '0' ]; then

	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo/web

	set -- gosu cuckoo /sbin/tini -- python manage.py runserver 0.0.0.0:31337

elif [ "$1" = 'stats' -a "$(id -u)" = '0' ]; then
	shift
	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo/utils

	set -- gosu cuckoo /sbin/tini -- python stats.py "$@"

elif [ "$1" = 'help' -a "$(id -u)" = '0' ]; then

	# Change the ownership of /cuckoo to cuckoo
	chown -R cuckoo:cuckoo /cuckoo
	cd /cuckoo

	set -- gosu cuckoo /sbin/tini -- python cuckoo.py --help
fi

exec "$@"
