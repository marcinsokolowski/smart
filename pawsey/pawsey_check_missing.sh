#!/bin/bash

obsid=1276619416
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

file_template="timestamps_?????.txt"
if [[ -n "$2" && "$2" != "-" ]]; then
   file_template=$2
fi

idg_images=0
if [[ -n "$3" && "$3" != "-" ]]; then
   idg_images=$3
fi


missing=0
ok=0
for timestamp in `cat $file_template`
do
   if [[ $idg_images -gt 0 ]]; then   
      stokes_base="wsclean_${obsid}_${timestamp}_briggs"
      # IDG in WSCLEAN :
      stokes_i=${timestamp}/${stokes_base}-I-image.fits
      stokes_q=${timestamp}/${stokes_base}-Q-image.fits
      stokes_u=${timestamp}/${stokes_base}-U-image.fits
      stokes_v=${timestamp}/${stokes_base}-V-image.fits
   else
      stokes_base="wsclean_${obsid}_${timestamp}_briggs-image"
     
      # python beam correction :
      stokes_i=${timestamp}/${stokes_base}_I.fits
      stokes_q=${timestamp}/${stokes_base}_Q.fits
      stokes_u=${timestamp}/${stokes_base}_U.fits
      stokes_v=${timestamp}/${stokes_base}_V.fits
   fi
   
   if [[ -s ${stokes_i} && -s ${stokes_q} && -s ${stokes_u} && -s ${stokes_v} ]]; then
      ok=$(($ok+1))
   else
      echo "Missing timestamp $timestamp - not processed yet ???"
      missing=$(($missing+1))
   fi
done


echo
echo "Total number of processed timestamps = $ok"
echo "Not processed timestamps             = $missing"
  