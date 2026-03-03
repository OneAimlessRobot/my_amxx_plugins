#!/bin/bash


sudo echo ""
echo "Launching steam..."
steam --no-browser +open steam://open/minigameslist&
echo "The pid of steam is: ${!}"
sudo renice -n 19 -p $!
echo "Just launched steam!"
