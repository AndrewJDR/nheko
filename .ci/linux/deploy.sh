#!/usr/bin/env bash

set -ex

APP=nheko
DIR=${APP}.AppDir
TAG=`git tag -l --points-at HEAD`

# Set up AppImage structure.
mkdir -p ${DIR}/usr/{bin,lib,share/pixmaps,share/applications}

# Copy resources.
cp build/nheko ${DIR}/usr/bin
cp resources/nheko.desktop ${DIR}/usr/share/applications/nheko.desktop
cp resources/nheko.png ${DIR}/usr/share/pixmaps/nheko.png

for iconSize in 16 32 48 64 128 256 512; do
    IconDir=${DIR}/usr/share/icons/hicolor/${iconSize}x${iconSize}/apps
    mkdir -p ${IconDir}
    cp resources/nheko-${iconSize}.png ${IconDir}/nheko.png
done

# Only download the file when not already present
if ! [ -f linuxdeployqt-continuous-x86_64.AppImage ] ; then
	wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
fi
chmod a+x linuxdeployqt*.AppImage

unset QTDIR
unset QT_PLUGIN_PATH 
unset LD_LIBRARY_PATH

export ARCH=$(uname -m)
export LD_LIBRARY_PATH=.deps/usr/lib/:$LD_LIBRARY_PATH

./linuxdeployqt*.AppImage ${DIR}/usr/share/applications/*.desktop -bundle-non-qt-libs
./linuxdeployqt*.AppImage ${DIR}/usr/share/applications/*.desktop -appimage

chmod +x nheko-*x86_64.AppImage

if [ ! -z $VERSION ]; then
    # commented out for now, as AppImage file appears to already contain the version.
    #mv nheko-*x86_64.AppImage nheko-${VERSION}-x86_64.AppImage
    echo "nheko-${VERSION}-x86_64.AppImage"
fi