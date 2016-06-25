# Cyberfox Install & Shortcut Desktop, Cyberfox uninstall
# Version: 1.2
# Release, Beta channels linux

#!/bin/bash

# Set current directory to script directory.
Dir=$(cd "$(dirname "$0")" && pwd)

# Enter current script directory.
cd $Dir

# Count how many packages in the directory, If there is more then one the script may break or have undesired effect.
PackageCount=`ls Cyberfox*.tar.bz2 | awk 'END { print NR }'` 

# Make package name editable in single place in the event of file naming change.
Package=$Dir/Cyberfox-*.tar.bz2

# Check if the script is in the right place before checking file hashes.
echo "Do you wish to install Cyberfox now?"
select yn in "Install" "Uninstall" "Quit"; do
    case $yn in
        Install )

        # Check if more than 1 package exist.
        if [ $PackageCount -gt 1 ]; then  
            echo "You have to many packages [$PackageCount] in this directory, I am unable to compute what package to install, Please remove the other packages so i no longer get confused!"
            exit 0 
        fi;


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
            echo "Unpacking $Package in to $HOME/Apps directory"
            tar xjfv $Package

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
            echo "Icon=$HOME/Apps/Cyberfox/browser/icons/mozicon128.png" >> ~/Desktop/cyberfox.desktop
            echo "Terminal=false" >> ~/Desktop/cyberfox.desktop
            echo "Type=Application" >> ~/Desktop/cyberfox.desktop
            echo "StartupNotify=true" >> ~/Desktop/cyberfox.desktop
            chmod +x ~/Desktop/cyberfox.desktop
            echo "Cyberfox is now ready for use!"
        else
            echo "You must place this script next to the 'Cyberfox' tar.bz2 package."
        fi; break;;
        Uninstall )

            # Navigate in to apps directory
            echo "Entering $HOME/Apps directory"
            cd $HOME/Apps

            # Remove cyberfox installation folder
            if [ -d $HOME/Apps/Cyberfox ]; then
                echo "Removing older install $HOME/Apps/Cyberfox"
                rm -rvf $HOME/Apps/Cyberfox;
            fi

            # Remove cyberfox desktop icon if exists.
            if [ -f ~/Desktop/cyberfox.desktop ]; then
                rm -vf ~/Desktop/cyberfox.desktop;
            fi
        break;;
	  "Quit" )
            echo "If I’m not back in five minutes, just wait longer."
			exit 0
		break;;
    esac
done