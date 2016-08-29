#!/bin/bash
# Built from template by hawkeye116477
# Full repo https://github.com/hawkeye116477/cyberfox-deb

# Set current directory to script directory.
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir

# Get package version including beta version if beta.
VERSION=$(<../../browser/config/version_display.txt)

# Generate template
CONTROLTEMPLATE=$Dir/deb/DEBIAN/control
cp _Templates/control deb/DEBIAN

# Copy latest build
mkdir $Dir/deb/usr/lib/Cyberfox
cp -R ../../../obj64/dist/Cyberfox/* $Dir/deb/usr/lib/Cyberfox
cp _Templates/Cyberfox.sh $Dir/deb/usr/lib/Cyberfox

# Apply information to template
cd $Dir/deb
if grep -q -E "__VERSION__|__SIZE__" "$CONTROLTEMPLATE" ; then
    sed -i "s|__VERSION__|$VERSION|" $CONTROLTEMPLATE   
    SIZE=$(du -s)
    sed -i "s|__SIZE__|${SIZE::-1}|" $CONTROLTEMPLATE
fi

# Generate file hashes
find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
cp -r DEBIAN/md5sums ../../../../obj64/dist
cd $Dir


# Build debian package
dpkg -b $Dir/deb ../../../obj64/dist/Cyberfox-$VERSION.en-US.linux-x86_64

# Clean up
rm -rf $Dir/deb/usr/lib/Cyberfox
rm -f $Dir/deb/DEBIAN/md5sums
cp $Dir/_Templates/control deb/DEBIAN