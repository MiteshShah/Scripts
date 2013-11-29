#!/bin/bash



# Add Crontab To Auto Start Scripts
# @reboot /bin/bash /root/bin/sync-with-inotify.sh &>> /var/log/sync-with-inotify.log &

# Configure Variables
DOMAIN=
SERVER1=
SERVER2=
SERVER2IP=


while true
do

	# Monitor Files Changes For Create, Delete, Move, File Permissions
	inotifywait --exclude .swp ~  -r -e create -e modify -e delete -e move -e attrib --format %e:%f /var/www/

	# Detect Server:
	# Detect.txt is soft linked to /usr/local/bin/Detect.txt
	# Detect.txt Contains Uniq Live/Backup Server Identify Strings
	curl -sL $DOMAIN/Detect.txt | grep -i $SERVER1
	

	if [ $? -eq 0 ]
	then

		# Send Details To Log Files
		echo "The $SERVER1 Server Is Running, Sending Changes From $SERVER1 To $SERVER2:"

		# Start Synchronisation
		#rsync --temp-dir=/tmp -avz --delete /var/www root@BACKUP-SERVER-IP:/var/
		rsync --temp-dir=/tmp -avz /var/www root@$SERVER2IP:/var/
	
		# If Rsync Fails
		if [ $? != 0 ]
		then

			echo "[+] Checking Server Health Script Is Already Running Or Not"
			ps ax | grep check-server-health.sh | grep -v grep

			if [ $? != 0 ]
			then
				echo "[+] Starting Check Server Health Script"
				bash /root/bin/check-server-health.sh &
			fi
		fi
		
	else
		# Send Details To Log Files
		echo "The $SERVER2 Is Running, Can't Sending Changes From $SERVER1 To $SERVER2:"
	fi
done
