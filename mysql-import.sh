#!/bin/bash



# Capture Errors
OwnError()
{
        echo -e "[ `date` ] \033[31m $@ \e[0m" | tee -ai $ERRORLOG
        exit 101 
}

apt-get -y install pv || OwnError "Unable To Install PV"


read -p "Database Pathe (/var/rsnap-mysql): " DBPATH

# IF Enter Is Pressed
if [[ $DBPATH = "" ]]
then
        DBPATH="/var/rsnap-mysql"
        echo $DBPATH
fi

for i in $DBPATH/*
do
        echo 
        echo
        read -p "Select Database For `basename $i`: " DB_NAME
        echo DBNAME = $DB_NAME 
        echo SQLFILE = $i
        mysql -e "create database `$DBNAME`" || OwnError  "Unable To Create Database $DBANME"
        pv $i | mysql $DB_NAME
done

