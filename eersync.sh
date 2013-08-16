#!/bin/bash
# This code is later added into easyengine migrate command
# Developed by Mitesh Shah & Manish Songirkar

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

echo -e " ============================================================\n `date` \n" | tee -ai $ERRORLOG
echo -e " SOURCE IP = $DOMAIN \n WPDBNAME = $WPDBNAME \n MYSQLUSER = $MYSQLUSER \n MYSQLPASS = $MYSQLPASS" | tee -ai $ERRORLOG
echo
echo -e "\033[34m Taking MySQL Dump...  \e[0m"
rm -rf /var/www/$DOMAIN/backup
mkdir -p /var/www/$DOMAIN/backup
mysqldump -u $MYSQLUSER -p$MYSQLPASS $WPDBNAME > /var/www/$DOMAIN/backup/$WPDBNAME.sql || OwnError "Unable To Dump MySQL For $WPDBNAME"

# Destination Domain
echo
echo " Required destination server details:"
read -p " Enter Usernames [www-data]: " DESTUSER
read -p " Enter Destination IP: " DESTIP
read -p " Enter Destination PORT [22]: " DESTPORT
read -p " Enter Destination Domain Name To rsync: " DESTDOMAIN
echo

# If Enter Is Pressed, Then Use www-data As Destination Username
if [[ $DESTUSER = "" ]]
then
	DESTUSER=www-data
	#echo $DESTUSER
fi

# If Enter Is Pressed, Then Use 22 As Destination Port
if [[ $DESTPORT = "" ]]
then
	DESTPORT=22
	#echo $DESTPORT
fi


# Lets Import MySQL
echo -e "\033[34m Fetching destination DB Name, DB User and DB Password...  \e[0m"
rsync -avzh $DESTUSER@$DESTIP:/var/www/$DESTDOMAIN/wp-config.php /tmp/ || OwnError "Unable to fetch wp-config.php file from $DESTDOMAIN"
DESTDBNAME=$(grep DB_NAME /tmp/wp-config.php | cut -d"'" -f4)
DESTDBUSER=$(grep DB_USER /tmp/wp-config.php | cut -d"'" -f4)
DESTDBPASS=$(grep DB_PASS /tmp/wp-config.php | cut -d"'" -f4)

echo -e " -----" | tee -ai $ERRORLOG
echo -e " DESTIP = $DESTIP \n DESTDBNAME = $DESTDBNAME \n DESTDBUSER = $DESTDBUSER \n DESTDBPASS = $DESTDBPASS" | tee -ai $ERRORLOG
read -p " Are You Sure To rsync $DOMAIN To $DESTDOMAIN (y/n): " ANSWER

if [ "$ANSWER" == "y" ]; then
	echo
	echo
	echo
	echo -e "\033[34m Please Wait...  \e[0m"
	rsync -avzh /var/www/$DOMAIN/htdocs /var/www/$DOMAIN/backup/$WPDBNAME.sql $DESTUSER@$DESTIP:/var/www/$DESTDOMAIN/
	echo -e "\033[34m Import MySQL, Please Wait...  \e[0m"
	ssh $DESTUSER@$DESTIP -p $DESTPORT "mysql -u $DESTDBUSER -p$DESTDBPASS $DESTDBNAME < /var/www/$DESTDOMAIN/$WPDBNAME.sql"
	rm -rf /tmp/wp-config.php
	echo
	echo -e "\033[34m rsync from $DOMAIN to $DESTDOMAIN completed. \e[0m"
	echo
	echo -e "\033[34m For the first time rsync, add following lines to $DESTDOMAIN/wp-config.php file  \e[0m"
	echo -e "\033[1;33m"
	echo " define( 'WP_HOME', 'http://$DESTDOMAIN/' );"
	echo " define( 'WP_SITEURL', 'http://$DESTDOMAIN/' );"
	echo -e "\e[0m"
	echo -e "IMPORTANT: Don't forget to install and run Search and Replace Plugin on Destination Site."
	echo
elif [ "$ANSWER" == "n" ]; then
	# User Denied Messages
	echo
	echo -e "\033[31m User Denied rsync from $DOMAIN to $DESTDOMAIN \e[0m" | tee -ai $ERRORLOG
	echo
fi
