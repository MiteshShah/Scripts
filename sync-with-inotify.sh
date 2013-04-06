#!/bin/bash
while true
do
	inotifywait --exclude .swp ~  -r -e create -e modify -e delete -e move -e attrib \
	--format %e:%f /var/www/mitesh.com/htdocs/
	rsync -avz /var/www/mitesh.com/htdocs/ root@192.168.0.206:/var/www/mitesh.com/htdocs/
done
