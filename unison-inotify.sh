#!/bin/bash



while true
do
        # Monitor Files Changes For Create, Delete, Move, File Permissions
        inotifywait --exclude .swp ~  -r -e create -e modify -e delete -e move -e attrib --format %e:%f /var/www/

	# Execute Unison
        unison -fastcheck false
done
