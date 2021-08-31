#!/bin/bash

export PATH="/opt/caastro/ext/anaconda/bin:$PATH"

stokes=I
if [[ -n "$1" && "$1" != "-" ]]; then
   stokes=$1
fi

ls mean_stokes_${stokes}_000*.fits > fits_list_${stokes}
ls rms_stokes_${stokes}_000*.fits > fits_rms_list_${stokes}

rm -f KEEGAN.last_processed_file KEEGAN_radius10px_${stokes}.txt
echo "monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_list_${stokes} \"--max\" -  10 KEEGAN_radius10px_${stokes}.txt"
monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_list_${stokes} "--max" -  10 KEEGAN_radius10px_${stokes}.txt

rm -f KEEGAN.last_processed_file KEEGAN_radius5px_${stokes}.txt
echo "monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_list_${stokes} \"--max\" -  5 KEEGAN_radius5px_${stokes}.txt"
monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_list_${stokes} "--max" -  5 KEEGAN_radius5px_${stokes}.txt

rm -f KEEGAN.last_processed_file KEEGAN_radius3px_${stokes}.txt
echo "monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_list_${stokes} \"--max\" -  3 KEEGAN_radius3px_${stokes}.txt"
monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_list_${stokes} "--max" -  3 KEEGAN_radius3px_${stokes}.txt

ls KEEGAN_radius*px_${stokes}.txt > lc_list_${stokes}.txt


rm -f KEEGAN.last_processed_file KEEGAN_radius10px_RMS_${stokes}.txt
echo "monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_rms_list_${stokes} \"--max\" -  10 KEEGAN_radius10px_RMS_${stokes}.txt"
monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_rms_list_${stokes} "--max" -  10 KEEGAN_radius10px_RMS_${stokes}.txt

rm -f KEEGAN.last_processed_file KEEGAN_radius5px_RMS_${stokes}.txt
echo "monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_rms_list_${stokes} \"--max\" -  5 KEEGAN_radius5px_RMS_${stokes}.txt"
monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_rms_list_${stokes} "--max" -  5 KEEGAN_radius5px_RMS_${stokes}.txt

rm -f KEEGAN.last_processed_file KEEGAN_radius3px_RMS_${stokes}.txt
echo "monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_rms_list_${stokes} \"--max\" -  3 KEEGAN_radius3px_RMS_${stokes}.txt"
monitor_source_radec.sh 6.64833333 -19.91857222 KEEGAN fits_rms_list_${stokes} "--max" -  3 KEEGAN_radius3px_RMS_${stokes}.txt


ls KEEGAN_radius*px_RMS_${stokes}.txt > lc_rms_list_${stokes}.txt

mkdir -p images/
root -q -l "plotNfiles_any_vs_time.C(\"lc_list_${stokes}.txt\")"
root -q -l "plotNfiles_any_vs_time.C(\"lc_rms_list_${stokes}.txt\")"

