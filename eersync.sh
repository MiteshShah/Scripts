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
read -p "Enter Source Domain Name To rsync: " DOMAIN

# MySQL Informatiom
WPDBNAME=$(grep DB_NAME /var/www/$DOMAIN/wp-config.php | cut -d"'" -f4)
MYSQLUSER=$(grep DB_USER /var/www/$DOMAIN/wp-config.php | cut -d"'" -f4)
MYSQLPASS=$(grep DB_PASS /var/www/$DOMAIN/wp-config.php | cut -d"'" -f4)
echo -e " WPDBNAME = $WPDBNAME \n MYSQLUSER = $MYSQLUSER \n MYSQLPASS = $MYSQLPASS" | tee -ai $ERRORLOG



echo "Take MySQL Dump: "
rm -rf /var/www/$DOMAIN/backup
mkdir -p /var/www/$DOMAIN/backup
mysqldump -u $MYSQLUSER -p$MYSQLPASS $WPDBNAME > /var/www/$DOMAIN/backup/$WPDBNAME.sql || OwnError "Unable To Dump MySQL For $WPDBNAME"

# Destination Domain
echo
echo
echo
echo
echo "We need some details of destination server:"
read -p "Enter Usernames: " DESTUSER
read -p "Enter Destination IP: " DESTIP
read -p "Enter Destination PORT: " DESTPORT
read -p "Enter Destination Domain Name To rsync: " DESTDOMAIN

# Lets Import MySQL
DESTDBNAME=$(ssh $DESTUSER@$DESTIP -p $DESTPORT "grep DB_NAME /var/www/$DESTDOMAIN/wp-config.php" | cut -d"'" -f4)
DESTDBUSER=$(ssh $DESTUSER@$DESTIP -p $DESTPORT "grep DB_USER /var/www/$DESTDOMAIN/wp-config.php" | cut -d"'" -f4)
DESTDBPASS=$(ssh $DESTUSER@$DESTIP -p $DESTPORT "grep DB_PASS /var/www/$DESTDOMAIN/wp-config.php" | cut -d"'" -f4)

echo -e " DESTDBNAME = $DESTDBNAME \n DESTDBUSER = $DESTDBUSER \n DESTDBPASS = $DESTDBPASS" | tee -ai $ERRORLOG
read -p "Are You Sure To rsync $DOMAIN To $DESTDOMAIN (y/n): " ANSWER

if [ "$ANSWER" = "y" ]
then
	echo
	echo
	echo
	echo
	echo "Please wait..."
	rsync -avzh /var/www/$DOMAIN/htdocs /var/www/$DOMAIN/backup/$WPDBNAME.sql $DESTUSER@$DESTIP:/var/www/$DESTDOMAIN/

	echo "Import MySQL, Please wait..."
	ssh $DESTUSER@$DESTIP -p $DESTPORT "mysql -u $DESTDBUSER -p$DESTDBPASS $DESTDBNAME < /var/www/$DESTDOMAIN/$WPDBNAME.sql"
	echo
	echo
	echo
	echo
	echo "Add following lines to wp-config.php file"
	echo
	echo "define( 'WP_HOME', 'http://$DESTDOMAIN/' );"
	echo "define( 'WP_SITEURL', 'http://$DESTDOMAIN/' );"
else
	# User Denied Messages
	echo -e "\033[31m User Denied To rsync $DOMAIN To $DESTDOMAIN. \e[0m"
fi
