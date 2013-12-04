#!/bin/bash


# Configure Variables
SERVER2IP=

while true
do
	# Check Server2 Become A Live
	ping -c1 $SERVER2IP &> /dev/null
	
	if [ $? == 0 ]
	then
		echo "[+] Server Becomes Alive......"
		rsync -avz --temp-dir=/tmp /var/www root@$SERVER2IP:/var/
		exit 0;
	fi
done
