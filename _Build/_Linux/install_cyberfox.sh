# Cyberfox Install & Shortcut Desktop
# Version: 1.1
# Release, Beta channels linux

#!/bin/bash

# Set current directory to script directory.
Dir=$(cd "$(dirname "$0")" && pwd)

# Enter current script directory.
cd $Dir

# Check if the script is in the right place before checking file hashes.
echo "Do you wish to install Cyberfox now?"
select yn in "Yes" "No" "Quit"; do
    case $yn in
        Yes )        
        if [ -f $Dir/Cyberfox*.tar.bz2 ]; then
            # Make directory if not already exist
            if ! [ -d $HOME/Apps ]; then
                echo "Making $HOME/Apps directory!"
                mkdir $HOME/Apps
            fi
            # Navigate in to apps directory
            echo "Entering $HOME/Apps directory"
            cd $HOME/Apps
            # Unpack cyberfox in to apps directory, Remove existing cyberfox folder.
            if [ -d $HOME/Apps/Cyberfox ]; then
                echo "Removing older install $HOME/Apps/Cyberfox"
                rm -rvf $HOME/Apps/Cyberfox;
            fi
            echo "Unpacking $Dir/Cyberfox-*.tar.bz2 in to $HOME/Apps directory"
            tar xjfv $Dir/Cyberfox-*.tar.bz2

            # Remove readme.txt it has no place in apps directory.
            if [ -f $HOME/Apps/README.txt ]; then
                rm -rvf $HOME/Apps/README.txt;
            fi

            # Create desktop shortcut
            echo "Generating desktop shortcut"
            echo "[Desktop Entry]" > ~/Desktop/cyberfox.desktop
            echo "Name=Cyberfox" >> ~/Desktop/cyberfox.desktop
            echo "Comment=Starts Cyberfox Web Browser" >> ~/Desktop/cyberfox.desktop
            echo "Exec=$HOME/Apps/Cyberfox/Cyberfox" >> ~/Desktop/cyberfox.desktop
            echo "Icon=cyberfox" >> ~/Desktop/cyberfox.desktop
            echo "Terminal=false" >> ~/Desktop/cyberfox.desktop
            echo "Type=Application" >> ~/Desktop/cyberfox.desktop
            echo "StartupNotify=true" >> ~/Desktop/cyberfox.desktop
            chmod +x ~/Desktop/cyberfox.desktop
            echo "Cyberfox is now ready for use!"
        else
            echo "You must place this script next to the 'Cyberfox' tar.bz2 package."
        fi; break;;
        No ) break;;
	  "Quit" )
            echo "If I’m not back in five minutes, just wait longer."
			exit 0
		break;;
    esac
done