#!/bin/bash
echo "Taking ownership of build directory..."
sudo chown -R build:build ${BAKEDIR}
echo "Updating git submodules..."
git submodule update --init
echo "Preparing bitbake environment..."
TEMPLATECONF=${BAKEDIR}/meta-redhawk-apps/conf source ${OECORE_ENV} ./build-pi ./bitbake
echo "Linking to build-image.sh script..."
ln -s ${BAKEDIR}/meta-redhawk-apps/contrib/scripts/build-image.sh ${BAKEDIR}/build-pi/
echo "Building image..."
./build-image.sh
