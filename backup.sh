#!/bin/bash

# Set up some variables for logging
LOGFILE="/var/log/duplicity/backup.log"
DAILYLOGFILE="/var/log/duplicity/backup.daily.log"
FULLBACKLOGFILE="/var/log/duplicity/backup.full.log"
HOST=`hostname`
DATE=`date +%Y-%m-%d`
MAILADDR="sys@rtcamp.com"
TODAY=$(date +%d%m%Y)

is_running=$(ps -ef | grep duplicity | grep -v grep | wc -l)

if [ ! -d /var/log/duplicity ];then
    mkdir -p /var/log/duplicity
fi

if [ $is_running -eq 0 ]; then
    # Clear the old daily log file
    cat /dev/null > ${DAILYLOGFILE}

    # Trace function for logging, don't change this
    trace () {
            stamp=`date +%Y-%m-%d_%H:%M:%S`
            echo "$stamp: $*" >> ${DAILYLOGFILE}
    }

    # Export some ENV variables so you don't have to type anything
    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""
    export PASSPHRASE=""

    # Your GPG key
    GPG_KEY=

    # How long to keep backups for
    OLDER_THAN="1M"

    # The source of your backup
    SOURCE=/

    # The S3 destination followed by bucket name
    DEST="s3://s3.amazonaws.com//"

    FULL=
    tail -1 ${FULLBACKLOGFILE} | grep ${TODAY}
    if [ $? -eq 0 && $(date +%d) -eq 1 ]; then
            FULL=full
    fi;

    trace "Backup for local filesystem started"

    trace "... removing old backups"

    duplicity remove-older-than ${OLDER_THAN} ${DEST} >> ${DAILYLOGFILE} 2>&1

    trace "... backing up filesystem"

    duplicity \
        ${FULL} \
        --encrypt-key=${GPG_KEY} \
        --sign-key=${GPG_KEY} \
        --include=/var/rsnap-mysql \
        --include=/var/www \
        --include=/etc \
        --exclude=/** \
        ${SOURCE} ${DEST} >> ${DAILYLOGFILE} 2>&1

    trace "Backup for local filesystem complete"
    trace "------------------------------------"

    # Send the daily log file by email
    #cat "$DAILYLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR
    BACKUPSTATUS=`cat "$DAILYLOGFILE" | grep Errors | awk '{ print $2 }'`
    if [ "$BACKUPSTATUS" != "0" ]; then
	   cat "$DAILYLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR
    elif [ $FULL == "full"]
        echo "$(date +%d%m%Y_%T) Full Back Done" >> $FULLBACKLOGFILE
    fi

    # Append the daily log file to the main log file
    cat "$DAILYLOGFILE" >> $LOGFILE

    # Reset the ENV variables. Don't need them sitting around
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset PASSPHRASE
fi
