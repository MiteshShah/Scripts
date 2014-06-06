#!/bin/bash
#1. if one instance is running, second should not start
#2. scan the files modified in last 24 hours
#3 full scan on sunday only



is_sunday=$(date +%u)

if [ $is_sunday -eq 7 ];then
	echo "Full clamscan is running...."
	clamscan --exclude=/proc --exclude=/sys --exclude=/dev -r -i / 
else
	echo "Running clamscan for file modified in last 24 hours...."
	is_running=$(ps -ef | grep clamscan | grep -v grep | wc -l)
	if [ $is_running -eq 0 ];then
		find / -not -wholename '/sys/*' -and -not -wholename '/proc/*' -mtime -1 -type f -print0 | xargs -0 -r clamscan -i 
	fi
fi

