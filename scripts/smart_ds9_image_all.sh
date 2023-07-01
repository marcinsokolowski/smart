#!/bin/bash

postfix=".fits"
if [[ -n "$1" && "$1" != "-" ]]; then
   postfix=$1
fi

for fits in `ls mean_stokes_?${postfix} rms_stokes_?${postfix}`
do
   echo "smart_ds9_image.sh ${fits} ${postfix}"
   smart_ds9_image.sh ${fits} ${postfix}
done
