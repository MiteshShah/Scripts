#!/bin/bash
while true
do
	ping -c1 BACKUP-SERVER-IP &> /dev/null
	#ping -c1 Live-SERVER-IP &> /dev/null
	if [ $? == 0 ]
	then
		echo "[+] Server Becomes Alive ......"
		rsync -avz --delete /var/www/ root@BACKUP-SERVER-IP:/var/www/
		#rsync -avz /var/www/ root@LIVE-SERVER-IP:/var/www/
		exit 0;
	fi
done
