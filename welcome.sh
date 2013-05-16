#!/bin/bash
#Welcome Script For
#Good Morning
#Good Afternoon
#Good Evening

TIME=$(date +%H)

#From 06:00:00 to 11:59:59 Good Morning
if [ $TIME -gt 05 ] && [ $TIME -lt 12 ]
then
	espeak -ven-us+f4 -s170 "Good Morning $(whoami)" &> /dev/null
	notify-send "Good Morning $(whoami)" 2> /dev/null

#From 12:00:00 to 16:59:59 Good Afternoon
elif [ $TIME -gt 11 ] && [ $TIME -lt 17 ]
then
	espeak -ven-us+f4 -s170 "Good Afternoon $(whoami)" &> /dev/null
	notify-send "Good Afternoon $(whoami)" 2> /dev/null

#From 17:00:00 to 19:59:59 Good Evening
elif [ $TIME -gt 16 ] && [ $TIME -lt 20 ]
then
	espeak -ven-us+f4 -s170 "Good Evening $(whoami)" &> /dev/null
	notify-send "Good Evening $(whoami)" 2> /dev/null

#From 20:00:00 to 05:59:59
else
	espeak -ven-us+f4 -s170 "Welcome $(whoami)" &> /dev/null
	notify-send "Welcome $(whoami)" 2> /dev/null
fi
