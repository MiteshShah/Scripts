#!/bin/bash
# Monitor SSH Authorised Keys
while true
do
	inotifywait --exclude .swp -e modify /root/.ssh/authorized_keys /home/*/.ssh/authorized_keys
	echo "SSH Authorised Keys Files Modified At [`date`]" &>> /var/log/rtsecure.log

	echo "SSH Authorised Keys Files Modified At `date`" | mail -s "rtCamp.com SSH Keys Modified" Mitesh.Shah@rtcamp.com 
	#nitun.lanjewar@rtcamp.com radhakrishnan.mudliar@rtcamp.com rahul.bansal@rtcamp.com
done
