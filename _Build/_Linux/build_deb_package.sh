#!/bin/bash
# Built from template by hawkeye116477
# Full repo https://github.com/hawkeye116477/cyberfox-deb
# Script Version: 1.0.2
# Set current directory to script directory.
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir

# Init vars
VERSION=""
CONTROLTEMPLATE=""

# Get package version including beta version if beta.
if [ -f "../../browser/config/version_display.txt" ]; then
    VERSION=$(<../../browser/config/version_display.txt)
else
    echo "Unable to get current build version!"
    exit 1    
fi

# Generate template
if [ -f "$Dir/deb/DEBIAN/control" ]; then
    CONTROLTEMPLATE=$Dir/deb/DEBIAN/control
    cp _Templates/control deb/DEBIAN
else
    echo "Unable to location control template!"
    exit 1    
fi

# Generate lib & cyberfox folder if not already created
if [ ! -d "$Dir/deb/usr/lib" ]; then
    mkdir $Dir/deb/usr/lib
    mkdir $Dir/deb/usr/lib/Cyberfox
fi

# Copy latest build
if [ -d "../../../obj64/dist/Cyberfox" ]; then
    cp -R ../../../obj64/dist/Cyberfox/* $Dir/deb/usr/lib/Cyberfox
    cp $Dir/_Templates/cyberfox.sh $Dir/deb/usr/lib/Cyberfox
else
    echo "Unable to Cyberfox package files, Please check the build was created and packaged successfully!"
    exit 1     
fi

# Apply information to template
cd $Dir/deb
if grep -q -E "__VERSION__|__SIZE__" "$CONTROLTEMPLATE" ; then
    sed -i "s|__VERSION__|$VERSION|" $CONTROLTEMPLATE   
    SIZE=$(du -s)
    sed -i "s|__SIZE__|${SIZE::-1}|" $CONTROLTEMPLATE
else
    echo "An error occured when trying to generate $CONTROLTEMPLATE information!"
    exit 1  
fi

# Generate file hashes
find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
cp -r DEBIAN/md5sums ../../../../obj64/dist
cd $Dir

# make sure correct permissions are set
chmod -R 755 $Dir/deb

# Build debian package
dpkg -b $Dir/deb ../../../obj64/dist/Cyberfox-$VERSION.en-US.linux-x86_64.deb

# Notify of package complete
if [ -f "../../../obj64/dist/Cyberfox-$VERSION.en-US.linux-x86_64.deb" ]; then
    notify-send "Debian package Complete"
fi

# Clean up
if [ -d "$Dir/deb/usr/lib" ]; then
    echo "Clean: $Dir/deb/usr/lib"
    rm -rf $Dir/deb/usr/lib
fi
if [ -f "$Dir/deb/DEBIAN/md5sums" ]; then
    echo "Clean: $Dir/deb/DEBIAN/md5sums"
    rm -f $Dir/deb/DEBIAN/md5sums
fi

# Add fresh template
cp $Dir/_Templates/control deb/DEBIAN