#!/bin/bash

if [[ $UID != 0 ]]; then
	echo "Please run with sudo:"
	echo "sudo $0 $*"
	exit 1
fi

ava="/etc/apache2/sites-available";
ena="/etc/apache2/sites-enabled";
root="/var/www/vhosts";
template="`dirname $0`/vhost-template.conf";

while getopts ":h:" opt; do
	case $opt in
		h)
			vhost="$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an arguement." >&2
			exit 1
			;;
	esac
done

if [[ -z "$vhost" ]]; then
	echo -e "Usage:\n\t`basename $0` <options>\n\nWhere <options> are:\n\n\t-h hostname" >&2
	exit 1
fi

if [[ ! -w "$ava" ]]; then
	echo "Not writeable: $ava"
	exit 2
fi


if [[ -e ${ava}/${vhost} ]]; then
	echo "${ava}/${vhost} already exists. Skipping.";
elif [[ -e ${ena}/${vhost} ]]; then
	echo "${ena}/${vhost} already exists. Skipping.";
elif [[ -e ${root}/${vhost} ]]; then
	echo "${root}/${vhost} already exists. Skipping.";
else
	if [[ ! -e ${template} ]]; then
		echo "${template} does not exist. Cannot create ${ava}/${vhost}.";
		exit 2
	else
		sed -e "s/%hostname%/$vhost/g" -e "s|%docroot%|$root|g" "${template}" > ${ava}/${vhost}.conf
		mkdir ${root}/${vhost}
	fi
fi

chown www-data:www-data "${ava}/${vhost}"
a2ensite "$vhost"
service apache2 reload
echo "Created new host under ${root}/${vhost}."
