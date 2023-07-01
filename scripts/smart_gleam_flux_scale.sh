#!/bin/bash

fitsfile=mean_stokes_I.fits
if [[ -n "$1" && "$1" != "-" ]]; then
   fitsfile=$1
fi

freq_cc=121
if [[ -n "$2" && "$2" != "-" ]]; then
   freq_cc=$2
fi

if [[ ! -s save_list ]]; then
   echo "DEBUG : file save_list does not exist -> creating one now :"
   echo "ls mean_stokes_?.fits rms_stokes_?.fits > save_list"
   ls mean_stokes_?.fits rms_stokes_?.fits > save_list
else
   echo "DEBUG : file save_list already exists"
fi

save_list=save_list
if [[ -n "$3" && "$3" != "-" ]]; then
   save_list=$3
fi

# By default noise is calculated a bit off the image center :
noise_x=980
if [[ -n "$4" && "$4" != "-" ]]; then
   noise_x=$4
fi

noise_y=980
if [[ -n "$5" && "$5" != "-" ]]; then
   noise_y=$5
fi

save_list=save_list
if [[ -n "$6" && "$6" != "-" ]]; then
   save_list=$6
fi


save_fits=flux_corrected/${fitsfile%%.fits}_CorrFlux.fits
out_file=${fitsfile%%fits}find_gleam

# echo "cp ${fitsfile} ${fitsfile}.backup"
# cp ${fitsfile} ${fitsfile}.backup

# echo "python $SMART_DIR/bin/smart_remove_2axis_keywords.py ${fitsfile}"
# python $SMART_DIR/bin/smart_remove_2axis_keywords.py ${fitsfile}

mkdir -p flux_corrected/
echo "python $SMART_DIR/bin/smart_find_gleam.py -f ${fitsfile} --freq_cc=${freq_cc} --save_list=${save_list} > ${out_file} 2>&1"
python $SMART_DIR/bin/smart_find_gleam.py -f ${fitsfile} --freq_cc=${freq_cc} --save_list=${save_list} > ${out_file} 2>&1


cd flux_corrected
echo "smart_rms_all.sh \"*_stokes_?_FluxCorr.fits\" $noise_x $noise_y 10"
smart_rms_all.sh "*_stokes_?_FluxCorr.fits" $noise_x $noise_y 10



