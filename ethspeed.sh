#!/bin/sh

# Make The Script Executable
SCRIPTPATH=`pwd`/$0
echo
echo "Script Absolute Path = $SCRIPTPATH"
echo "Make Script Executable"
sudo chmod 755 $SCRIPTPATH

# Make A New Directory In /Etc
echo
if [ -d /etc/rtcamp ]
then
	echo "/etc/rtcamp Directory Exist"
else
	echo "Creating /etc/rtcamp Directory"
	sudo mkdir /etc/rtcamp
fi

echo
echo "Copy Script in /etc/rtcamp/"
sudo cp -v $SCRIPTPATH /etc/rtcamp/

# Check Ethtool Is Installed
dpkg --list | grep ethtool &> /dev/null

if [ $? -eq 0 ]
then
	echo
	echo "Ethtool Already Installed "
else
	echo
	echo "Installing Ethtool... "
	sudo apt-get install ethtool
fi


# Set Ethtool Path
echo
ETHTOOL=$(whereis ethtool | cut -d: -f2 | cut -d' ' -f2)
echo Ethtool Path = $ETHTOOL

# Findout No Of Ethernet Cards
echo
DEVICES=$(lshw -class network | grep ' logical name' | cut -d: -f2 | cut -d' ' -f2 | tr '\n' ' ')
echo "Ethernet Cards = $DEVICES"


for SET in $DEVICES
do
	echo
	echo
	echo "Setting $SET Speed 1GB/s Duplex Full... "
	$ETHTOOL -s $SET autoneg off speed 100 duplex full;
	$ETHTOOL -s $SET autoneg off speed 1000 duplex full;
	$ETHTOOL -s $SET autoneg on;
done

# Add Script To RC.LOCAL
cat /etc/rc.local | grep ethspeed.sh &> /dev/null
echo
if [ $? -eq 0 ]
then
	echo "Already Script Entry in /etc/rc.local"
else
	echo "Adding Script Entry in /etc/rc.local"
	sed -i '$ i\/etc/rtcamp/ethspeed.sh' /etc/rc.local
fi
