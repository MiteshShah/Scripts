#!/bin/sh
SHORTCUT="[Desktop Entry]
Name=Sublime Text 2.0.1
Comment=Edit Text Files
Exec=/opt/sublime-text-2/sublime_text
Icon=/opt/sublime-text-2/Icon/128x128/sublime_text.png
Terminal=false
Type=Application
Encoding=UTF-8
Categories=Utility;TextEditor;"

SCRIPT="#!/bin/bash
if [ \"\$1\" == \"--help\" ]
then
    /opt/sublime-text-2/sublime_text --help
else
    /opt/sublime-text-2/sublime_text \$@ > /dev/null 2>&1 &
fi"

cd /opt/
wget -c http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.tar.bz2
tar -xvjf "Sublime Text 2.0.1 x64.tar.bz2"
mv /opt/"Sublime Text 2" /opt/sublime-text-2

echo "${SCRIPT}" > "/usr/local/bin/subl"
chmod +x "/usr/local/bin/subl"
echo "${SHORTCUT}" > "/usr/share/applications/sublime-text-2.desktop"

echo "Finish!"
