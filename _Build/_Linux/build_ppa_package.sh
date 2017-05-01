#!/bin/bash
# Built from template by hawkeye116477
# Full repo https://github.com/hawkeye116477/cyberfox-deb
# Script Version: 1.0

# Set current directory to directory of package.
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir/ppa/ppa

# Get package version including beta version if beta.
if [ -f "../../../browser/config/version_display.txt" ]; then
    VERSION=$(<../../../browser/config/version_display.txt)
else
    echo "Unable to get current build version!"
    exit 1    
fi

# Copy template for copyright
if [ -f "$Dir/_Templates/copyright" ]; then
    cp $Dir/_Templates/copyright $Dir/ppa/debian
else
    echo "Unable to locate copyright template!"
    exit 1 
fi

# Generate lib & cyberfox folder if not already created
if [ ! -d "$Dir/deb/usr/lib" ]; then
    mkdir $Dir/ppa/ppa/usr/lib
    mkdir $Dir/ppa/ppa/usr/lib/Cyberfox
fi

# Copy latest build
if [ -d "../../../../obj64/dist/Cyberfox" ]; then
    cp -R ../../../../obj64/dist/Cyberfox/* $Dir/ppa/ppa/usr/lib/Cyberfox
    cp $Dir/_Templates/Cyberfox.sh $Dir/ppa/ppa
	cp $Dir/_Templates/vendor-gre.js $Dir/ppa/ppa
else
    echo "Unable to Cyberfox package files, Please check the build was created and packaged successfully!"
    exit 1     
fi

    if [ -f "$Dir/ppa/debian/copyright" ]; then
        sed -i "s|__SOURCE__|$SOURCE|" $Dir/ppa/ppa/debian/copyright
    else
        echo "An error occured when trying to generate $Dir/deb/debian/copyright information!"
        exit 1 
    fi

# Make sure correct permissions are set
chmod  755 $Dir/ppa/ppa/debian/control
chmod  755 $Dir/ppa/ppa/debian/prerm
chmod  755 $Dir/ppa/ppa/debian/copyright

# Make symlinks
ln -s /usr/lib/Cyberfox/Cyberfox.sh $Dir/ppa/ppa/cyberfox
ln -s /usr/lib/Cyberfox/browser/icons/mozicon128.png $Dir/ppa/ppa/Cyberfox.png

# Build package for upload to PPA
debuild -S -sa

# Upload package to ppa
cd $Dir/ppa
dput ppa:8pecxstudios/cyberfox-next cyberfox-$VERSION-0~ppa1.source.changes

# Clean up
if [ -d "$Dir/ppa/usr/lib" ]; then
    echo "Clean: $Dir/ppa/usr/lib"
    rm -rf $Dir/ppa/ppa/usr/lib
fi
if [ -f "$Dir/ppa/DEBIAN/copyright" ]; then
    echo "Clean: $Dir/ppa/DEBIAN/copyright"
    rm -f $Dir/ppa/ppa/debian/copyright
fi
if [ -f "$Dir/ppa/" ]; then
    echo "Clean rubbish from: $Dir/ppa/"
    rm -f $Dir/ppa/cyberfox-$VERSION-0~ppa1.dsc
	rm -f $Dir/ppa/cyberfox-$VERSION-0~ppa1.tar.gz
	rm -f $Dir/ppa/cyberfox-$VERSION-0~ppa1.source.build
	rm -f $Dir/ppa/cyberfox-$VERSION-0~ppa1.source.changes
fi
