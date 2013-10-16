#!/bin/bash


# Configure Variables
SERVER2IP=

while true
do
	# Select Live/Backup Server
	ping -c1 $SERVER2IP &> /dev/null
	
	if [ $? == 0 ]
	then
		echo "[+] Server Becomes Alive ......"
		#rsync -avz /var/www root@LIVE-SERVER-IP:/var/
		rsync -avz /var/www root@$SERVER2IP:/var/
		exit 0;
	fi
done
