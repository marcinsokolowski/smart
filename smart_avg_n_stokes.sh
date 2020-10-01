#!/bin/bash

n=120 # `ls *_I.fits |wc -l`
if [[ -n "$1" && "$1" != "-" ]]; then
   n=$1
fi

for stokes in `echo "I Q U V"`
do
   ls wsclean*-image_${stokes}.fits > fits_stokes_${stokes}
   
   index=0
   rm -f tmp_list
   touch tmp_list
   for fits in `cat fits_stokes_${stokes}`
   do
      cnt=`cat tmp_list | wc -l`
      
      if [[ $cnt -lt $n ]]; then
         echo $fits >> tmp_list
         # i=$(($i+1))
      else
         i_str=`echo $index | awk '{printf("%05d",$1);}'`
      
         echo "avg_images tmp_list mean_stokes_${stokes}_${i_str}.fits rms_stokes_${stokes}_${i_str}.fits"
         avg_images tmp_list mean_stokes_${stokes}_${i_str}.fits rms_stokes_${stokes}_${i_str}.fits
            
         echo "rm -f tmp_list"
         rm -f tmp_list
         touch tmp_list
         
         index=$((index+1))
      fi      
   done
   
   ls mean_stokes_${stokes}_?????.fits > mean_fits_stokes_${stokes}_list
   ls rms_stokes_${stokes}_?????.fits > rms_fits_stokes_${stokes}_list
   
   echo "python $SMART_DIR/bin/dump_pixel_simple.py mean_fits_stokes_${stokes}_list --radius=2 --outfile=mean_fits_stokes_${stokes}.txt --time_step=${n}"
   python $SMART_DIR/bin/dump_pixel_simple.py mean_fits_stokes_${stokes}_list --radius=2 --outfile=mean_fits_stokes_${stokes}.txt --time_step=${n}

   echo "python $SMART_DIR/bin/dump_pixel_simple.py rms_fits_stokes_${stokes}_list --radius=2 --outfile=rms_fits_stokes_${stokes}.txt --time_step=${n}"
   python $SMART_DIR/bin/dump_pixel_simple.py rms_fits_stokes_${stokes}_list --radius=2 --outfile=rms_fits_stokes_${stokes}.txt --time_step=${n}
   
   awk '{if($1!="#"){print $1" "$5;}}' mean_fits_stokes_${stokes}.txt > mean${stokes}.txt
   awk '{if($1!="#"){print $1" "$5;}}' rms_fits_stokes_${stokes}.txt > rms${stokes}.txt

   awk '{if($1!="#"){print $1" "$8;}}' mean_fits_stokes_${stokes}.txt > sum_mean${stokes}.txt
   awk '{if($1!="#"){print $1" "$8;}}' rms_fits_stokes_${stokes}.txt > sum_rms${stokes}.txt

   mkdir -p images/   
   root -q -b -l "plotfile.C(\"mean${stokes}.txt\")"
   root -q -b -l "plotfile.C(\"rms${stokes}.txt\")"
   root -q -b -l "plotfile.C(\"sum_mean${stokes}.txt\")"
   root -q -b -l "plotfile.C(\"sum_rms${stokes}.txt\")"
done
