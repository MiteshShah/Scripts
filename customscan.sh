#!/bin/bash
#1. if one instance is running, second should not start
#2. scan the files modified in last 24 hours
#3. full scan on Sunday only

is_sunday=$(date +%u)
tmp_file=/tmp/filetoscan.txt
filetoscan=100
daily_log=/var/log/clamscan/scan.daily.log
log=/var/log/clamscan/scan.log
mailid=gaurav.astikar@rtcamp.com

if [ ! -d  /var/log/clamscan ];then
	mkdir -p /var/log/clamscan
fi

> $daily_log

if [ $is_sunday -eq 7 ];then
	echo "Full clamscan is running...." >> $daily_log
	clamscan --exclude=/proc --exclude=/sys --exclude=/dev -r -i / >> $daily_log
else
	echo "Running clamscan for file modified in last 24 hours...." >> $daily_log
	is_running=$(ps -ef | grep clamscan | grep -v grep | wc -l)
	if [ $is_running -eq 0 ];then
		find / -not -wholename '/sys/*' -and -not -wholename '/proc/*' -mtime -1 -type f -print0 | xargs -0 -r clamscan -i >> $daily_log
	fi
fi

grep -v /home/clamav/infected/ $daily_log | grep ' FOUND'
if [ $? -eq 0 ];then
	cat $daily_log | mail -s "ClamAv Result For $(hostname)" $mailid
fi
cat $daily_log >> $log
