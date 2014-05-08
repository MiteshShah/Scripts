#!/bin/bash


# -------------------------------------------------------------------------
# Modified By: Mitesh Shah
# Copyright (c) 2007 Vivek Gite <vivek@nixcraft.com>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------


### Handle Kernal Signals ####
HandleSignals()
{
	echo -e \\t \\t "Rsnapshot-MySQL Script (Failed) Caught Termination Signal" &>> $RsnapLOGS/rsnap-mysql.log

	#Unset Trap So We Don't Get Infinate Loop
	trap - INT TERM QUIT ABRT KILL

	#Flush File System Buffers
	#More Details: info coreutils 'sync invocation'
	sync

	#Exit The Script
	exit 0
}
trap "HandleSignals" INT TERM QUIT ABRT KILL



### Set Bins Path ###
RM=/bin/rm
GZIP=/bin/gzip
GREP=/bin/grep
MKDIR=/bin/mkdir
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQLADMIN=/usr/bin/mysqladmin


### SETUP MySQL LOGIN ###
if [ -f ~/.my.cnf ]
then
	MySQLUSER=$(cat ~/.my.cnf | grep user | cut -d'=' -f2)
	MySQLPASS=$(cat ~/.my.cnf | grep pass | cut -d'=' -f2)
else
	read -p "Enter The MySQL Username: " MySQLUSER

	# Turn Off Echo For Passwords
	stty -echo
	read -p "Enter The MySQL Password: " MySQLPASS
	stty echo
	echo
fi

HOSTIP="127.0.0.1"

### Enable Log = 1 ###
LOGS=1

### Default Time Format ###
TIME_FORMAT='%d%b%Y%H%M%S'
 

### Setup Dump And Log Directory ###
RsnapROOT=/var/rsnap-mysql
RsnapLOGS=/var/log/rsnap-mysql


#####################################
### ----[ No Editing below ]------###
#####################################

### Die On Demand With Message ###
die(){
	echo "$@"
	exit 999
}


### Make Sure Bins Exists ###
verify_bins(){
	[ ! -x $GZIP ] && die "File $GZIP does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQL ] && die "File $MYSQL does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQLDUMP ] && die "File $MYSQLDUMP does not exists. Make sure correct path is set in $0."
	[ ! -x $RM ] && die "File $RM does not exists. Make sure correct path is set in $0."
	[ ! -x $MKDIR ] && die "File $MKDIR does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQLADMIN ] && die "File $MYSQLADMIN does not exists. Make sure correct path is set in $0."
	[ ! -x $GREP ] && die "File $GREP does not exists. Make sure correct path is set in $0."
}


### Make Sure We Can Connect To The Server ###
verify_mysql_connection(){
	$MYSQLADMIN  -u $MySQLUSER -h $HOSTIP -p$MySQLPASS ping | $GREP 'alive' > /dev/null
	[ $? -eq 0 ] || die "Error: Cannot connect to MySQL Server. Make sure username and password are set correctly in $0"
}


### Make A Backup ###
backup_mysql_rsnapshot(){
        local DBS="$($MYSQL -u $MySQLUSER -h $HOSTIP -p$MySQLPASS -Bse 'show databases')"
        local db="";

	[ ! -d $RsnapLOGS ] && $MKDIR -p $RsnapLOGS
        [ ! -d $RsnapROOT ] && $MKDIR -p $RsnapROOT
        $RM -f $RsnapROOT/* > /dev/null 2>&1

	[ $LOGS -eq 1 ] && echo "" &>> $RsnapLOGS/rsnap-mysql.log
	[ $LOGS -eq 1 ] && echo "*** Dumping MySQL Database At $(date) ***" &>> $RsnapLOGS/rsnap-mysql.log
	[ $LOGS -eq 1 ] && echo "Database >> " &>> $RsnapLOGS/rsnap-mysql.log

        for db in $DBS
        do
                local TIME=$(date +"$TIME_FORMAT")
                local FILE="$RsnapROOT/$db.$TIME.gz"
		[ $LOGS -eq 1 ] && echo -e \\t "$db" &>> $RsnapLOGS/rsnap-mysql.log
		
		if [  $db = "mysql" ]
		then
                	$MYSQLDUMP --events --single-transaction -u $MySQLUSER -h $HOSTIP -p$MySQLPASS $db | $GZIP -9 > $FILE || echo -e \\t \\t "MySQLDump Failed $db"
                else
                	$MYSQLDUMP --single-transaction -u $MySQLUSER -h $HOSTIP -p$MySQLPASS $db | $GZIP -9 > $FILE || echo -e \\t \\t "MySQLDump Failed $db"
                fi
        done
		[ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $RsnapROOT] ***" &>> $RsnapLOGS/rsnap-mysql.log
}


### Main ####
verify_bins
verify_mysql_connection
backup_mysql_rsnapshot
