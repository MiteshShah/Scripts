#!/bin/bash

# Start Work With Update
apt-get update
apt-get upgrade

# Install Commonly Used Packages
apt-get -y install vim screen clamav inotify-tools fail2ban mailutils pv

# Download MySQL Performance Optimize Tool
wget -cO /usr/local/bin/tuning-primer.sh https://launchpadlibrarian.net/78745738/tuning-primer.sh
chmod u+x /usr/local/bin/tuning-primer.sh


# Allow Localhost To Connect Port 25 (Postfix)
iptables -A INPUT -p tcp -s 127.0.0.0/8 --dport 25 -j ACCEPT
iptables -A INPUT -p tcp --dport 25 -j DROP
