#!/bin/bash

remove_naxis=1
if [[ -n "$1" && "$1" != "-" ]]; then
   remove_naxis=$1
fi

if [[ ! -s fits_list_XX ]]; then
   ls *__XX_*.fits > fits_list_XX
fi

for fits_xx in `cat fits_list_XX`
do
   fits_yy=`echo $fits_xx | awk '{gsub("_XX","_YY");print $1;}'`
   fits_I=`echo $fits_xx | awk '{gsub("_XX","_I");print $1;}'`

   if [[ ! -s $fits_I ]]; then
      echo "calcfits_bg $fits_xx A $fits_yy $fits_I"
      calcfits_bg $fits_xx A $fits_yy $fits_I
   else
      echo "WARNING : $fits_I already exists -> use option force is want to overwrite"
   fi
done

ls *_I*.fits > fits_list_I

# fix header :
for fits in `cat fits_list_I`
do
   gps=`echo $fits |cut -b 1-10`
   ux=`gps2ux! $gps`
   lst=`ux2sid $ux | awk '{print $8;}'`   

   echo "python $BIGHORNS//software/analysis/scripts/python/fixCoordHdr.py $fits $lst ${remove_naxis}"
   python $BIGHORNS//software/analysis/scripts/python/fixCoordHdr.py $fits $lst ${remove_naxis}
done

# MEAN / RMS :
echo "avg_images fits_list_I mean_I.fits rms_I.fits"
avg_images fits_list_I mean_I.fits rms_I.fits 
