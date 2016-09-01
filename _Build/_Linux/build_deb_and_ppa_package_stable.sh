#!/bin/bash
# Built from template by hawkeye116477
# Full repo https://github.com/hawkeye116477/cyberfox-deb
# Script Version: 1.0

# Init vars
VERSION=""

# Get package version.
if [ -f "../../../browser/config/version_display.txt" ]; then
    VERSION=$(<../../../browser/config/version_display.txt)
else
    echo "Unable to get current build version!"
    exit 1    
fi

# Create needed folders 
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir/
mkdir debs # Create folder where move created .deb packages
mkdir deb_and_ppa_stable
cd $Dir/deb_and_ppa_stable/
mkdir cyberfox-$VERSION
cd $Dir/deb_and_ppa_stable/cyberfox-$VERSION/
mkdir debian 
mkdir usr
cd $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/
mkdir share
cd $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/share/
mkdir applications
mkdir lintian
cd $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/
mkdir lib
cd $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/lib/
mkdir Cyberfox

#Set current directory to directory of package.
cd $Dir/deb_and_ppa_stable/cyberfox-$VERSION

# Copy PPA templates
if [ -f "$Dir/deb_and_ppa_templates/stable/" ]; then
	cp -avr $Dir/deb_and_ppa_templates/stable/ $Dir/deb_and_ppa_stable/cyberfox-$VERSION/debian/
else
    echo "Unable to locate ppa templates!"
    exit 1 
fi

# Copy template for copyright
if [ -f "$Dir/deb_and_ppa_templates/copyright" ]; then
    cp $Dir/deb_and_ppa_templates/copyright $Dir/deb_and_ppa_stable/cyberfox-$VERSION/debian
else
    echo "Unable to locate copyright template!"
    exit 1 
fi

# Copy latest build
if [ -d "../../../../obj64/dist/Cyberfox" ]; then
    cp -R ../../../../obj64/dist/Cyberfox/* $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/lib/Cyberfox
	cp $Dir/deb_and_ppa_templates/cyberfox.desktop $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/share/applications
	cp $Dir/deb_and_ppa_templates/Cyberfox $Dir/deb_and_ppa_stable/cyberfox-$VERSION/usr/share/lintian/overrides
    cp $Dir/deb_and_ppa_templates/Cyberfox.sh $Dir/deb_and_ppa_stable/cyberfox-$VERSION
	cp $Dir/deb_and_ppa_templates/vendor-gre.js $Dir/deb_and_ppa_stable/cyberfox-$VERSION
else
    echo "Unable to Cyberfox package files, Please check the build was created and packaged successfully!"
    exit 1     
fi

# Make sure correct permissions are set
chmod  755 $Dir/deb_and_ppa_/cyberfox-$VERSION/debian/control
chmod  755 $Dir/deb_and_ppa_stable/cyberfox-$VERSION/debian/prerm
chmod  755 $Dir/deb_and_ppa_stable/cyberfox-$VERSION/debian/copyright

# Make symlinks
ln -s /usr/lib/Cyberfox/Cyberfox.sh $Dir/deb_and_ppa_stable/cyberfox-$VERSION/cyberfox
ln -s /usr/lib/Cyberfox/browser/icons/mozicon128.png $Dir/deb_and_ppa_stable/cyberfox-$VERSION/Cyberfox.png

# Build .deb package
debuild -us
mv $Dir/deb_and_ppa_stable/cyberfox-$VERSION-0~ppa1_amd64.deb $Dir/debs/Cyberfox-$VERSION.en-US.linux-x86_64.deb

# Build package for upload to PPA
debuild -S -sa

# Upload package to cyberfox PPA
cd $Dir/deb_and_ppa
dput ppa:8pecxstudios/cyberfox cyberfox-$VERSION-0~ppa1.source.changes

# Clean up
if [ -f "$Dir/deb_and_ppa_stable" ]; then
    echo "Clean: $Dir/deb_and_ppa_stable"
    rm -rf $Dir/deb_and_ppa_stable
fi
