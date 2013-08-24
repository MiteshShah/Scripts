#!/bin/bash
for i in /var/rsnap-mysql/*
do
        echo
        echo
        read -p "Select Database For `basename $i`: " DB_NAME
        echo DBNAME = $DB_NAME 
        echo SQLFILE = $i
        pv $i | mysql $DB_NAME
done

