#!/bin/bash
#
# Script to notify admin user if Linux,FreeBSD load crossed certain limit
# It will send an email notification to admin.
#
# Copyright 2005 (c) nixCraft project
# This is free script under GNU GPL version 2.0 or above.
# Support/FeedBack/comment :  Contact / Email us
# Tested os:
# * RedHat Linux
# * Debain Linux
# * FreeBSD
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit Bash Shell Scripting Directory For Linux / UNIX for more information.
# -------------------------------------------------------------------------
# Set up limit below
NOTIFY="22.0"
# admin user email id
EMAIL="Mitesh.Shah@rtcamp.com"
# Subject for email
SUBJECT="Alert $(hostname) load average"
# -----------------------------------------------------------------
# Os Specifc tweaks do not change anything below ;)
OS="$(uname)"
TRUE="1"
if [ "$OS" == "FreeBSD" ]; then
        TEMPFILE="$(mktemp /tmp/$(basename $0).tmp.XXX)"
        FTEXT='load averages:'
elif [ "$OS" == "Linux" ]; then
        TEMPFILE="$(mktemp)"
        FTEXT='load average:'
fi
# get first 5 min load
F5M="$(uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f1)"
# 10 min
F10M="$(uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f2)"
# 15 min
F15M="$(uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f3)"

# mail message
# keep it short coz we may send it to page or as an short message (SMS)
echo "Load average Crossed allowed limit $NOTIFY." >> $TEMPFILE
echo "Hostname: $(hostname)" >> $TEMPFILE
echo "Local Date & Time : $(date)" >> $TEMPFILE
# Look if it crossed limit
# compare it with last 15 min load average
RESULT=$(echo "$F15M > $NOTIFY" | bc)
# if so send an email
if [ "$RESULT" == "$TRUE" ]; then
    echo "-------------------------------------------" >> $TEMPFILE
    echo "System snapshot from top:" >> $TEMPFILE
    echo "-------------------------------------------" >> $TEMPFILE
    top -b -n1 >> $TEMPFILE
        mail -s "$SUBJECT" "$EMAIL" < $TEMPFILE
fi
# remove file
rm -f $TEMPFILE
