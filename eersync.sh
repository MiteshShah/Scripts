#!/bin/bash


ERRORLOG=/var/log/eersync.log
# Capture Errors
OwnError()
{
	echo -e "[ `date` ] \033[31m $@ \e[0m" | tee -ai $ERRORLOG
	exit 101
}


# Souce Domain
read -p " Enter Source Domain Name To rsync: " DOMAIN

# MySQL Informatiom
WPDBNAME=$(grep DB_NAME /var/www/$DOMAIN/wp-config.php | cut -d"'" -f4)
MYSQLUSER=$(grep DB_USER /var/www/$DOMAIN/wp-config.php | cut -d"'" -f4)
MYSQLPASS=$(grep DB_PASS /var/www/$DOMAIN/wp-config.php | cut -d"'" -f4)

echo -e " WPDBNAME = $WPDBNAME \n MYSQLUSER = $MYSQLUSER \n MYSQLPASS = $MYSQLPASS" | tee -ai $ERRORLOG

echo -e "\033[34m Taking MySQL Dump, Please Wait...  \e[0m"
mkdir -p /var/www/$DOMAIN/backup
rm -rf /var/www/$DOMAIN/backup/$WPDBNAME.sql

mysqldump -u $MYSQLUSER -p$MYSQLPASS $WPDBNAME > /var/www/$DOMAIN/backup/$WPDBNAME.sql || OwnError "Unable To Dump MySQL For $WPDBNAME"


# Destination Domain
echo
echo -e " Required Destination Server Details: "
read -p " Enter Usernames [www-data]: " DESTUSER
read -p " Enter Destination IP: " DESTIP
read -p " Enter Destination PORT [22]: " DESTPORT
read -p " Enter Destination Domain Name To rsync: " DESTDOMAIN
echo

# If Enter Is Pressed, Then Destination User = www-data
if [[ $DESTUSER = "" ]]
then
	DESTUSER=www-data
fi

# If Enter Is Pressed, Then Destination Port = 22
if [[ $DESTPORT = "" ]]
then
	DESTPORT=22
fi


# Lets Import MySQL
echo -e "\033[34m Fetching Destination DB Name, DB User & DB Password...  \e[0m"
rm -f /tmp/wp-config.php
rsync -avzh $DESTUSER@$DESTIP:/var/www/$DESTDOMAIN/wp-config.php /tmp/ || OwnError "Unable To Fetch wp-config.php From $DESTDOMAIN"

DESTDBNAME=$(grep DB_NAME /tmp/wp-config.php | cut -d"'" -f4)
DESTDBUSER=$(grep DB_USER /tmp/wp-config.php | cut -d"'" -f4)
DESTDBPASS=$(grep DB_PASS /tmp/wp-config.php | cut -d"'" -f4)

echo -e " DESTIP = $DESTIP \n DESTDBNAME = $DESTDBNAME \n DESTDBUSER = $DESTDBUSER \n DESTDBPASS = $DESTDBPASS" | tee -ai $ERRORLOG


read -p " Are You Sure To rsync $DOMAIN To $DESTDOMAIN (y/n): " ANSWER

if [ "$ANSWER" == "y" ]
then
	echo -e "\033[34m Sync $DOMAIN To $DESTDOMAIN, Please Wait...  \e[0m"
	rsync -avzh /var/www/$DOMAIN/htdocs /var/www/$DOMAIN/backup/$WPDBNAME.sql $DESTUSER@$DESTIP:/var/www/$DESTDOMAIN/ || OwnError "Unable To Sync $DOMAIN To $DESTDOMAIN"

	echo -e "\033[34m Importing MySQL, Please Wait...  \e[0m"
	ssh $DESTUSER@$DESTIP -p $DESTPORT "mysql -u $DESTDBUSER -p$DESTDBPASS $DESTDBNAME < /var/www/$DESTDOMAIN/$WPDBNAME.sql" || OwnError "Unable To Import MySQL On $DESTDOMAIN"
	ssh $DESTUSER@$DESTIP -p $DESTPORT "rm -f /var/www/$DESTDOMAIN/$WPDBNAME.sql" || OwnError "Unable To Remove MySQL Backup File $WPDBNAME.sql"

	echo -e "\033[34m For The First Time rsync, Add Following Lines To /var/www/$DESTDOMAIN/wp-config.php  \e[0m"
	echo -e "\033[1;33m \n define( 'WP_HOME', 'http://$DESTDOMAIN/' ); \n define( 'WP_SITEURL', 'http://$DESTDOMAIN/' ); \e[0m"
	echo -e "IMPORTANT: Don't Forget To Use Search & Replace Plugin"

elif [ "$ANSWER" == "n" ]
then
	# User Denied Messages
	echo
	echo -e "\033[31m User Denied rsync from $DOMAIN to $DESTDOMAIN \e[0m" | tee -ai $ERRORLOG
fi
