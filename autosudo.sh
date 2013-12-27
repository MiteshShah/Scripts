#!/bin/bash

FILE=$1

# Check We Have A Wrire Permission
if [ -w $FILE ]
then
        /usr/bin/vim $FILE
else
	# Use Sudo If We Dont Have Write Permissions
        sudo /usr/bin/vim $FILE
fi
