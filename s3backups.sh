#!/bin/bash



### Handle Kernal Signals ####
HandleSignals()
{
	echo -e \\t \\t "s3backups Script (Failed) Caught Termination Signal" &>> $LOGS

	#Unset Trap So We Don't Get Infinate Loop
	trap - INT TERM QUIT ABRT KILL

	#Flush File System Buffers
	#More Details: info coreutils 'sync invocation'
	sync

	#Exit The Script
	exit 0
}
trap "HandleSignals" INT TERM QUIT ABRT KILL


OwnError()
{
	echo -e "[ `date` ] \033[31m $@ \e[0m" | tee -ai $LOGS
	exit 101
}

LOGS=/var/log/s3backups.log
DOMAIN=Domain.com
DBUSER=root
DBPASSWORD=PASSWORD
DBNAME=DBNAME
S3BUCKET=Domain
DIRNAME=Backups

TIME=$(date +'%d_%b_%Y')
DELETETIME=$(date --date "15 days ago" +'%d_%b_%Y')
echo $TIME $DELETETIME

rm -f /var/www/s3backups/$DOMAIN-htdocs-$DELETETIME.tar.gz
rm -f /var/www/s3backups/$DOMAIN-mysql-$DELETETIME.gz

# Backup $DOMAIN WebRoot
echo "[`date`] Backup $DOMAIN WebRoot..." &>> $LOGS
tar -zcvf /var/www/s3backups/$DOMAIN-htdocs-$TIME.tar.gz /var/www/$DOMAIN/htdocs \
|| OwnError "Failed Backup $DOMAIN WebRoot"

# Backup $DOMAIN MySQL
echo "[`date`] Backup $DOMAIN MySQL..." &>> $LOGS
mysqldump --single-transaction -u $DBUSER -p$DBPASSWORD $DBNAME | /bin/gzip -9 > /var/www/s3backups/$DOMAIN-mysql-$TIME.gz \
|| OwnError "Failed Backup $DOMAIN MySQL"


# Start S3Sync
ruby /root/s3sync/s3sync.rb -rv --delete --ssl /var/www/s3backups/ $S3BUCKET:$DIRNAME \
|| OwnError "Unable Process s3sync" &>> $LOGS

