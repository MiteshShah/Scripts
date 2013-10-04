#!/bin/sh



# Lets Download SubLime Text Editor
cd /opt/
wget -c http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3047_x64.tar.bz2
tar -xvjf "sublime_text_3_build_3047_x64.tar.bz2"
mv /opt/sublime_text_3 /opt/sublime-text-3

# Desktop Entry
SHORTCUT="[Desktop Entry]
Name=Sublime Text 3
Comment=Edit Text Files
Exec=/opt/sublime-text-3/sublime_text
Icon=/opt/sublime-text-3/Icon/128x128/sublime-text.png
Terminal=false
Type=Application
Encoding=UTF-8
Categories=Utility;TextEditor;"

# Help Script
SCRIPT="#!/bin/bash
if [ \"\$1\" == \"--help\" ]
then
    /opt/sublime-text-3/sublime_text --help
elif [ \"\$1\" == \"-v\" ] || [ \"\$1\" == \"--version\" ]
then
	/opt/sublime-text-3/sublime_text --version
else
    /opt/sublime-text-3/sublime_text \$@ > /dev/null 2>&1 &
fi"

echo "${SCRIPT}" > "/usr/local/bin/subl"
chmod +x "/usr/local/bin/subl"
echo "${SHORTCUT}" > "/usr/share/applications/sublime-text-3.desktop"

echo "Finish!"
