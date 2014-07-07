#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
service monit status | grep not
if [ $? -eq 0 ]; then
	#service monit restart
	service monit restart
	echo "Monit restarted on server $(hostname)" | mail -s "Monit restarted on $(hostname)" sys@rtcamp.com
fi

