#!/bin/bash


#Error Handling
OwnError()
{
    #Redirect All STDIN 2 STDOUT
    echo $@ >&2
    exit 1
}


# Unhide Startup
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop


#Update The Cache
clear
echo "Updating Cache..."
sudo apt-get update || OwnError "Updating Cache Failed :("

# Install Apt-Add-Repository Python Tool
sudo apt-get install python-software-properties || OwnError "Unable To Install Python Software Properties :(" 


#Google Repository 
clear
echo "Install Repository For Google..."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - || OwnError "Unable To Fetch Google Repository  :("
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list' || OwnError "Unable To Add Google Repository  :("

#Opera Repository 
clear
echo "Install Repository For Opera..."
wget -q -O - http://deb.opera.com/archive.key | sudo apt-key add - || OwnError "Unable To Fetch Opera Repository  :("
sudo sh -c 'echo "deb http://deb.opera.com/opera/ stable non-free" >> /etc/apt/sources.list.d/opera.list' || OwnError "Unable To Add Opera Repository  :("

#Skype Repository 
clear
echo "Install Repository For Skype..."
sudo sh -c  'echo "deb http://archive.canonical.com/ubuntu/ raring partner" >> /etc/apt/sources.list.d/canonical_partner.list' || OwnError "Unable To Add Skype Repository  :("

#Shutter Repository
clear
echo "Install Repository For Shutter..."
sudo add-apt-repository ppa:shutter/ppa || OwnError "Unable To Add Shutter Repository  :("

#Update The Cache
clear
echo "Updating Cache..."
sudo apt-get update || OwnError "Updating Cache Failed :("


#Install Common Softwares
clear
echo "Installing Git Vim Filezilla Google-Chrome Skype Oracle-Jdk"
sudo apt-get -y install git-core openssh-server shutter pv vim vlc curl filezilla google-chrome-stable skype sni-qt sni-qt:i386 libasound2-plugins:i386 openjdk-7-jre icedtea-7-plugin openjdk-7-jdk || OwnError "Installation Failed :("

#Install Netbeans
clear
echo "Downloading Netbeans..."
wget -c http://mitesh.rtcamp.info/Linux/netbeans-7.3.1-php-linux.sh
wget -c http://dlc.sun.com.edgesuite.net/netbeans/7.3.1/final/bundles/netbeans-7.3.1-php-linux.sh || OwnError "Unable to download Netbeans :("
chmod u+x netbeans-7.3.1-php-linux.sh
echo "Installing Netbeans..."
sudo bash netbeans-7.3.1-php-linux.sh || OwnError "Unable to install Netbeans :("
clear


#Install Web Server
curl -sL rt.cx/ee | sudo bash || OwnError "Unable to clone ee :("
source /etc/bash_completion.d/ee || OwnError "Unable to source ee autocompletion :("
echo
echo "All Task Susscessfully Finished........"
