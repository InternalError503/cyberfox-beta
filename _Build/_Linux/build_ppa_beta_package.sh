#!/bin/bash
# Built from template by hawkeye116477
# Full repo https://github.com/hawkeye116477/cyberfox-deb
# Script Version: 1.0

# Init vars
VERSION=""

# Get package version including beta version if beta.
if [ -f "../../../browser/config/version_display.txt" ]; then
    VERSION=$(<../../../browser/config/version_display.txt)
else
    echo "Unable to get current build version!"
    exit 1    
fi

# Set current directory to directory of package.
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir/
mkdir ppa
cd $Dir/ppa/
mkdir cyberfox-$VERSION
cd $Dir/ppa/cyberfox-$VERSION

# Copy PPA templates and other needed files
if [ -f "$Dir/ppa_templates/" ]; then
	cp -avr $Dir/ppa_templates/ $Dir/ppa/cyberfox-$VERSION/
else
    echo "Unable to locate ppa templates and other needed files!"
    exit 1 
fi

# Copy template for copyright
if [ -f "$Dir/_Templates/copyright" ]; then
    cp $Dir/_Templates/copyright $Dir/ppa/cyberfox-$VERSION/debian
else
    echo "Unable to locate copyright template!"
    exit 1 
fi

# Generate lib & cyberfox folder if not already created
if [ ! -d "$Dir/ppa/cyberfox-$VERSION/usr/lib" ]; then
    mkdir $Dir/ppa/cyberfox-$VERSION/usr/lib
    mkdir $Dir/ppa/cyberfox-$VERSION/usr/lib/Cyberfox
fi

# Copy latest build
if [ -d "../../../../obj64/dist/Cyberfox" ]; then
    cp -R ../../../../obj64/dist/Cyberfox/* $Dir/ppa/cyberfox-$VERSION/usr/lib/Cyberfox
    cp $Dir/_Templates/Cyberfox.sh $Dir/ppa/cyberfox-$VERSION
	cp $Dir/ppa_templates/vendor-gre.js $Dir/ppa/cyberfox-$VERSION
else
    echo "Unable to Cyberfox package files, Please check the build was created and packaged successfully!"
    exit 1     
fi

    if [ -f "$Dir/ppa/cyberfox-$VERSION/debian/copyright" ]; then
        sed -i "s|__SOURCE__|$SOURCE|" $Dir/ppa/cyberfox-$VERSION/debian/copyright
    else
        echo "An error occured when trying to generate $Dir/ppa/cyberfox-$VERSION/debian/copyright information!"
        exit 1 
    fi

# Make sure correct permissions are set
chmod  755 $Dir/ppa/cyberfox-$VERSION/debian/control
chmod  755 $Dir/ppa/cyberfox-$VERSION/debian/prerm
chmod  755 $Dir/ppa/cyberfox-$VERSION/debian/copyright

# Make symlinks
ln -s /usr/lib/Cyberfox/Cyberfox.sh $Dir/ppa/cyberfox-$VERSION/cyberfox
ln -s /usr/lib/Cyberfox/browser/icons/mozicon128.png $Dir/ppa/cyberfox-$VERSION/Cyberfox.png

# Build package for upload to PPA
debuild -S -sa

# Upload package to cyberfox-next PPA (cyberfox-beta)
cd $Dir/ppa
dput ppa:8pecxstudios/cyberfox-next cyberfox-$VERSION-0~ppa1.source.changes

# Clean up
if [ -f "$Dir/ppa" ]; then
    echo "Clean: $Dir/ppa"
    rm -rf $Dir/ppa
fi
