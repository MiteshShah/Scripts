#!/bin/bash
while true
do
	inotifywait --exclude .swp ~  -r -e create -e modify -e delete -e move -e attrib \
	--format %e:%f /var/www/
	rsync -avz --delete /var/www/ root@BACKUP-SERVER-IP:/var/www/
	#rsync -avz /var/www/ root@LIVE-SERVER-IP:/var/www/
done
