#!/bin/bash
# POV: You're an Arch user
if [ $(($RANDOM%6)) == 0 ]; then 
    echo "Click"
    sudo yay -Syu
fi
