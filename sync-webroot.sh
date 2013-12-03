#!/bin/bash



# Add Crontab To Auto Start Scripts
# @reboot /bin/bash /root/bin/sync-with-inotify.sh &>> /var/log/sync-with-inotify.log &

# Configure Variables
SERVER1=
SERVER2=
SERVER2IP=


while true
do

	# Monitor Files Changes For Create, Delete, Move, File Permissions
	inotifywait --exclude .swp -r -e create -e modify -e delete -e move -e attrib --format %e:%f /var/www/

	# Send Details To Log Files
	echo "[$(date)] Sending Changes From $SERVER1 To $SERVER2:"

	# Start Synchronisation
	rsync -avz --temp-dir=/tmp /var/www root@$SERVER2IP:/var/

	# If Rsync Fails
	if [ $? != 0 ]
	then

		echo "[+] Checking Server Health Script Is Already Running Or Not"
		ps ax | grep check-server-health.sh | grep -v grep

		if [ $? != 0 ]
		then
			echo "[+] Starting Check Server Health Script"
			/bin/bash /root/bin/check-server-health.sh &
		fi
	fi
done
