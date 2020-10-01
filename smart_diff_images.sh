#!/bin/bash

list=fits_list_I
if [[ -n "$1" && "$1" != "-" ]]; then
   list=$1
fi

stokes=I
if [[ -n "$2" && "$2" != "-" ]]; then
   stokes=$2
fi


index=0
prev_fits=""

mkdir -p diff_images/

while read fits_file # example 
do
   diff_file=${fits_file%%.fits}_diff.fits

   if [[ $index -ge 1 ]]; then
      echo "calcfits_bg $fits_file - $prev_fits diff_images/$diff_file"
      calcfits_bg $fits_file - $prev_fits diff_images/$diff_file
   else 
      echo "First file $fits_file skipped"
   fi   

   prev_fits=$fits_file
   index=$(($index+1))
done < $list

cd diff_images/
ls *_${stokes}_diff.fits > diff_fits_list_${stokes}

rms_path=`which rms.py`
echo "python $rms_path diff_fits_list_${stokes} --x=1024 --y=1024 --radius=10 > rms_diff.out 2>&1"
python $rms_path diff_fits_list_${stokes} --x=1024 --y=1024 --radius=10 > rms_diff.out 2>&1
grep wsclean rms_diff.out | grep AUTO | awk '{print $9;}' > rms_diff.txt
root -b -q "histofile.C(\"rms_diff.txt\",0,1,0,1)"

# sd9all! 1 - - "chan_204*_${stokes}_diff.fits" - - "images_${stokes}_diff/"
