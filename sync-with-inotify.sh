#!/bin/bash
while true
do
	# Monitor Files Changes For Create, Delete, Move, File Permissions
        inotifywait --exclude .swp ~  -r -e create -e modify -e delete -e move -e attrib --format %e:%f /var/www/

	# Rsync When Files Changed
	rsync -avz /var/www/ root@LIVE-SERVER-IP:/var/www/
        #rsync -avz --delete /var/www/ root@BACKUP-SERVER-IP:/var/www/
	
	# If Rsync Fails
	if [ $? != 0 ]
	then

		echo "[+] Checking Server Health Script Is Already Running Or Not ....."
		ps ax | grep check-server-health.sh | grep -v grep

		if [ $? != 0 ]
		then
			echo "[+] Starting Check Server Health Script ....."
			bash /root/bin/check-server-health.sh &
		fi
	fi
done
