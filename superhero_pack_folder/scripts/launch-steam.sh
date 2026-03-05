#!/bin/bash


sudo echo ""
echo "Launching steam..."
#open -a steam -vgui
steam --no-browser +open -TCP -vgui steam://open/minigameslist&
#steam -vgui&
#steam --no-browser -TCP -vgui  steam://open/minigameslist -forcesteamupdate -forcepackagedownload -overridepackageurl http://web.archive.org/web/20230531115543if_/media.steampowered.com/client -exitsteam&
echo "The pid of steam is: ${!}"
#sudo renice -n 19 -p $!
echo "Just launched steam!"
