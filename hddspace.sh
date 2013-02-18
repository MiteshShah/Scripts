#!/bin/bash

# Checking Disk Uses
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do

	echo $output
	uses=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
	partition=$(echo $output | awk '{ print $2 }' )

	# Send Mails On Low Disk Space
	if [ $uses -ge 90 ]
	then
		echo "Running Out Of Space \"$partition ($uses%)\" On $(hostname) As On $(date)" \
		| mail -s "Alert: Almost Out Of Disk Space $uses% On $(hostname)" Mitesh.Shah@rtCamp.com
	fi

done
