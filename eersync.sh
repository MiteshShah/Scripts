#!/bin/bash

# Usage : 
# 	Download eersync.sh to /tmp/ directory
# 	cd /tmp; wget -c https://raw.github.com/MiteshShah/Scripts/master/eersync.sh
# 	
# 	
# 	Run eersync.sh
# 	cd /tmp; bash eersync.sh <Source Domain> <Destination Domain>



# EasyEngine Domain Migration
MIGSRCDOMAIN=$1
MIGDESTDOMAIN=$2

# rsync Log file location
MIGRATELOG=/var/log/easyengine/eersync.log

if [ ! -f $MIGRATELOG ]
then
	sudo touch $MIGRATELOG
	sudo chmod 666 $MIGRATELOG
fi

# Check IF Source Added in Command
if [ -z "$MIGSRCDOMAIN" ]
then
	read -p " Enter Source Domain Name To rsync: " MIGSRCDOMAIN
fi

MIGSRCCONFIG=/var/www/$MIGSRCDOMAIN/wp-config.php

# Check If wp-config.php file exist or not
if [ -f $MIGSRCCONFIG ]
then
	MIGDBEXPORT=y
elif [ -f /var/www/$MIGSRCDOMAIN/htdocs/wp-config.php ]
then
	MIGDBEXPORT=y
	MIGSRCCONFIG=/var/www/$MIGSRCDOMAIN/htdocs/wp-config.php
else
	MIGDBEXPORT=n
fi

if [ "$MIGDBEXPORT" == "y" ]
then
	# MySQL Informatiom
	MIGSRCDBNAME=$(grep DB_NAME $MIGSRCCONFIG | cut -d"'" -f4)
	MIGSRCDBUSER=$(grep DB_USER $MIGSRCCONFIG | cut -d"'" -f4)
	MIGSRCDBPASS=$(grep DB_PASS $MIGSRCCONFIG | cut -d"'" -f4)

	echo -e "\n `date`" &>> $MIGRATELOG
	echo -e "\n Source Domain = $MIGSRCDOMAIN \n Source DB Name = $MIGSRCDBNAME \n Source MySQL User = $MIGSRCDBUSER \n Source MySQL Password = $MIGSRCDBPASS" | tee -ai $MIGRATELOG

	echo -e "\033[34m \n Taking MySQL Dump, Please Wait... \n \e[0m"
	
	# Check if not /backup directory is present
	if [ ! -d /var/www/$MIGSRCDOMAIN/backup ]
	then
		mkdir -p /var/www/$MIGSRCDOMAIN/backup
	else
		rm -rf /var/www/$MIGSRCDOMAIN/backup/$MIGSRCDBNAME.sql
	fi

	mysqldump --max_allowed_packet=512M -u $MIGSRCDBUSER -p$MIGSRCDBPASS $MIGSRCDBNAME > /var/www/$MIGSRCDOMAIN/backup/$MIGSRCDBNAME.sql || SyncError "Unable To Dump MySQL For $MIGSRCDBNAME"
else
	echo -e "\n `date`" &>> $MIGRATELOG
	echo -e "\n Source Domain = $MIGSRCDOMAIN" | tee -ai $MIGRATELOG
fi

# Destination Domain
echo -e " Required Destination Server Details: "

# Check IF Destination Added in Command
if [ -z "$MIGDESTDOMAIN" ]
then
	read -p " Enter Destination Domain Name To rsync: " MIGDESTDOMAIN
fi

read -p " Enter Usernames [www-data]: " MIGDESTUSER
read -p " Enter Destination IP: " MIGDESTIP
read -p " Enter Destination PORT [22]: " MIGDESTDBPORT

# If Enter Is Pressed, Then Destination User = www-data
if [[ $MIGDESTUSER = "" ]]
then
	MIGDESTUSER=www-data
fi

# If Enter Is Pressed, Then Destination Port = 22
if [[ $MIGDESTDBPORT = "" ]]
then
	MIGDESTDBPORT=22
fi

# Ignore Database
if [ "$MIGDBEXPORT" == "y" ]
then
	# Lets Import MySQL
	echo -e "\033[34m Fetching Destination DB Name, DB User & DB Password...  \e[0m"
	rsync -dmavzh --include "/*" --include "wp-config.php" --exclude "*" $MIGDESTUSER@$MIGDESTIP:/var/www/$MIGDESTDOMAIN/wp-config.php /tmp/ || SyncError "Unable To Fetch wp-config.php From $MIGDESTDOMAIN"

	# Rename wp-config file name to avoid conflict
	if [ -d /tmp/htdocs ]
	then
		mv /tmp/htdocs/wp-config.php /tmp/$MIGDESTDOMAIN-wp-config.php
		rm -rf /tmp/htdocs
	else
		mv /tmp/wp-config.php /tmp/$MIGDESTDOMAIN-wp-config.php
	fi

	# Get Destination Database Name, Username and Password
	MIGDESTDBNAME=$(grep DB_NAME /tmp/$MIGDESTDOMAIN-wp-config.php | cut -d"'" -f4)
	MIGDESTDBUSER=$(grep DB_USER /tmp/$MIGDESTDOMAIN-wp-config.php | cut -d"'" -f4)
	MIGDESTDBPASS=$(grep DB_PASS /tmp/$MIGDESTDOMAIN-wp-config.php | cut -d"'" -f4)
	echo -e "\n Destination Domain = $MIGDESTDOMAIN \n Destination DB Name = $MIGDESTDBNAME \n Destination MySQL User = $MIGDESTDBUSER \n Destination MySQL Password = $MIGDESTDBPASS \n" | tee -ai $MIGRATELOG
else
	echo -e "\n Destination Domain = $MIGDESTDOMAIN \n" | tee -ai $MIGRATELOG
fi

read -p " Are You Sure To rsync $MIGSRCDOMAIN To $MIGDESTDOMAIN (y/n) [y]: " MIGPERMISSION

# If Enter Is Pressed, Then User Sure for Migration = y
if [[ $MIGPERMISSION = "" ]]
then
	MIGPERMISSION=y
fi

if [ "$MIGPERMISSION" == "y" ]
then
	echo -e "\033[34m Sync $MIGSRCDOMAIN To $MIGDESTDOMAIN, Please Wait...  \e[0m"
	
	if [ "$MIGDBEXPORT" == "y" ]
	then
		# Ask for Exclude Directory
		read -p " Do You Want To Sync Uploads Directory (y/n) [y]: " MIGSYNCUPLOAD

		# If Enter Is Pressed, Then Sync Upload Directory = y
		if [[ $MIGSYNCUPLOAD = "" ]]
		then
			MIGSYNCUPLOAD=y
		fi

		if [ "$MIGSYNCUPLOAD" == "n" ]
		then
			rsync -avzh --exclude="wp-content/uploads/" /var/www/$MIGSRCDOMAIN/htdocs /var/www/$MIGSRCDOMAIN/backup/$MIGSRCDBNAME.sql $MIGDESTUSER@$MIGDESTIP:/var/www/$MIGDESTDOMAIN/ || SyncError "Unable To Sync $MIGSRCDOMAIN To $MIGDESTDOMAIN"
		else
			rsync -avzh /var/www/$MIGSRCDOMAIN/htdocs /var/www/$MIGSRCDOMAIN/backup/$MIGSRCDBNAME.sql $MIGDESTUSER@$MIGDESTIP:/var/www/$MIGDESTDOMAIN/ || SyncError "Unable To Sync $MIGSRCDOMAIN To $MIGDESTDOMAIN"
		fi

		# Ask for Import Database from Source to Destination
		read -p " Do You Want to Import MySQL Database from $MIGSRCDOMAIN to $MIGDESTDOMAIN (y/n) [y]: " MIGDBIMPORT

		# If Enter Is Pressed, Then Database Import = y
		if [[ $MIGDBIMPORT = "" ]]
		then
			MIGDBIMPORT=y
		fi

		if [ "$MIGDBIMPORT" == "y" ]
		then
			echo -e "\033[34m Importing MySQL, Please Wait...  \e[0m"
			ssh $MIGDESTUSER@$MIGDESTIP -p $MIGDESTDBPORT "mysql -u $MIGDESTDBUSER -p$MIGDESTDBPASS $MIGDESTDBNAME < /var/www/$MIGDESTDOMAIN/$MIGSRCDBNAME.sql" || SyncError "Unable To Import MySQL On $MIGDESTDOMAIN"
		else
			echo -e "\033[31m User Denied to Import Database from $MIGSRCDOMAIN to $MIGDESTDOMAIN \n \e[0m" | tee -ai $MIGRATELOG
		fi
	else
		rsync -avzh /var/www/$MIGSRCDOMAIN/htdocs $MIGDESTUSER@$MIGDESTIP:/var/www/$MIGDESTDOMAIN/ || SyncError "Unable To Sync $MIGSRCDOMAIN To $MIGDESTDOMAIN"
	fi

	if [ "$MIGDBEXPORT" == "y" ]
	then
		# Add WP_HOME and WP_SITEURL to wp-config.php file
		if ! grep -w -q WP_HOME /tmp/$MIGDESTDOMAIN-wp-config.php && ! grep -w -q WP_SITEURL /tmp/$MIGDESTDOMAIN-wp-config.php
		then
			ssh $MIGDESTUSER@$MIGDESTIP -p $MIGDESTDBPORT "echo -e \"\ndefine( 'WP_HOME', 'http://$MIGDESTDOMAIN' ); \ndefine( 'WP_SITEURL', 'http://$MIGDESTDOMAIN' ); \" >> /var/www/$MIGDESTDOMAIN/wp-config.php" || SyncError "Unable To Add WP_HOME and WP_SITEURL in /var/www/$MIGDESTDOMAIN/wp-config.php"
			echo -e "Added WP_HOME and WP_SITEURL to /var/www/$MIGDESTDOMAIN/wp-config.php"
		fi

		# Display Important Information After Completing rsync Process
		echo -e "\033[34m \nIMPORTANT: Don't Forget To Use Search & Replace Plugin \n \e[0m"

		# Remove Config file from /tmp/ Directory and Database backup file from Destination
		rm -f /tmp/$MIGDESTDOMAIN-wp-config.php
		ssh $MIGDESTUSER@$MIGDESTIP -p $MIGDESTDBPORT "rm -f /var/www/$MIGDESTDOMAIN/$MIGSRCDBNAME.sql" || SyncError "Unable To Remove MySQL Backup File $MIGSRCDBNAME.sql"
	fi
	echo -e "\033[34m \n http://$MIGDESTDOMAIN/ Domain Successfully Migrated \n \e[0m"
else
	# User Denied Messages
	echo
	echo -e "\033[31m User Denied rsync from $MIGSRCDOMAIN to $MIGDESTDOMAIN \e[0m" | tee -ai $MIGRATELOG
fi
