#!/bin/bash
sudo chown -R build:build ${BAKEDIR}/build
TEMPLATECONF=${BAKEDIR}/meta-redhawk-apps/conf . ${OECORE_ENV} ./build ./bitbake
ln -s ${BAKEDIR}/meta-redhawk-sdr/contrib/scripts/build-image.sh ${BAKEDIR}/build/
./build-image.sh
