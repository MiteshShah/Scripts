#!/bin/bash



# Configure Gmail

GMAILUSER=GmailUserName
GMAILPASS='GmailPasswprd'
echo $GMAILPASS

curl -u $GMAILUSER:$GMAILPASS https://mail.google.com/mail/feed/atom > /tmp/GmailChecker
COUNT=`cat /tmp/GmailChecker | grep fullcount | cut -d'>' -f2 | cut -d '<' -f1`

for i in `seq 1 $COUNT`
do
	TITLE=`cat /tmp/GmailChecker | grep -v 'Gmail - Inbox' | grep title | sed -n $i\p | cut -d'>' -f2 | cut -d '<' -f1`
	SUMMARY=`cat /tmp/GmailChecker | grep summary | sed -n $i\p | cut -d'>' -f2 | cut -d '<' -f1`
	echo $TITLE
	notify-send --icon kmail "($i/$COUNT) $TITLE <br><br> $SUMMARY"
done
