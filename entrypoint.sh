#!/bin/bash

set -e

export AFP_USER=pi
export AFP_GROUP=pi
export AFP_DIRECTORY=/netatalk

if [[ ! -e /.initialized_user ]]; then
	if [ -z $AFP_GID -o -z $AFP_UID ]; then
		export AFP_UID=1000
		export AFP_GID=1000
	fi
	echo "Set UID/GID as $AFP_UID/$AFP_GID"

	if [[ $(getent passwd $AFP_USER) ]]; then
		echo "NOTICE: $AFP_USER is exists, ignore create."
	else
		addgroup -g $AFP_GID $AFP_GROUP
		adduser -u $AFP_UID -G $AFP_GROUP -S -H $AFP_USER
		echo "User $AFP_USER($AFP_UID) with group $AFP_GROUP($AFP_GID) is added."
	fi

	if [[ -d $AFP_DIRECTORY ]]; then
		chown -R $AFP_USER:$AFP_GROUP $AFP_DIRECTORY
	fi

	if [[ -z $AFP_PASSWORD ]]; then
		export AFP_PASSWORD="paspberry" # default password
	fi

	echo $AFP_USER:$AFP_PASSWORD | chpasswd
	echo "NOTICE: Changed $AFP_USER's password as $AFP_PASSWORD"

	touch /.initialized_user
fi

# Start netatalk!
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
