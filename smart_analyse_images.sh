#!/bin/bash

# pixels 1039,1024 or 1025,1024

remove_naxis=1
if [[ -n "$1" && "$1" != "-" ]]; then
   remove_naxis=$1
fi

do_fix_coord=0
if [[ -n "$2" && "$2" != "-" ]]; then
   do_fix_coord=$2
fi

template="-XX-image.fits"
if [[ -n "$3" && "$3" != "-" ]]; then
   template=$3
fi
template_I=`echo $template | awk '{gsub("XX","I");print $1}'`


ls *${template} > fits_list_XX

for fits_xx in `cat fits_list_XX`
do
   fits_yy=`echo $fits_xx | awk '{gsub("XX","YY");print $1;}'`
   fits_I=`echo $fits_xx | awk '{gsub("XX","I");print $1;}'`
   stat_file_I=${fits_I%%fits}stat

   if [[ ! -s $fits_I ]]; then
      echo "calcfits_bg $fits_xx A $fits_yy $fits_I"
      calcfits_bg $fits_xx A $fits_yy $fits_I
   else
      echo "WARNING : $fits_I already exists -> use option force is want to overwrite"
   fi
   
   echo "calcfits_bg ${fits_I} s > ${stat_file_I}"
   calcfits_bg ${fits_I} s > ${stat_file_I}
done

ls *${template_I}* > fits_list_I

if [[ $do_fix_coord -gt 0 ]]; then
   # fix header :
   for fits in `cat fits_list_I`
   do
      echo "python $BIGHORNS//software/analysis/scripts/python/fixCoordHdr.py $fits -1000 ${remove_naxis}"
      python $BIGHORNS//software/analysis/scripts/python/fixCoordHdr.py $fits -1000 ${remove_naxis}
   done
else
   echo "WARNING : calling fixCoordHdr.py is not request - please verify if this is acceptable !"
fi   

# MEAN / RMS :
echo "avg_images fits_list_I mean_I.fits rms_I.fits"
avg_images fits_list_I mean_I.fits rms_I.fits 


# REMEMBER X,Y OTHER WAY AROUND with respect to ds9 :
echo "python $BIGHORNS/software/analysis/scripts/python/dump_pixel_simple.py fits_list_I 1039 1024"
python $BIGHORNS/software/analysis/scripts/python/dump_pixel_simple.py fits_list_I 1039 1024


date
echo "diff_images.sh fits_list_I"
diff_images.sh fits_list_I


ls *diff.fits > diff_list_I
echo "python $BIGHORNS/software/analysis/scripts/python/dump_pixel_simple.py diff_list_I 1039 1024 0 timeseries_diff --ap_radius=5"
python $BIGHORNS/software/analysis/scripts/python/dump_pixel_simple.py diff_list_I 1039 1024 0 timeseries_diff --ap_radius=5

echo "avg_images diff_list_I diff_mean_I.fits diff_rms_I.fits"
avg_images diff_list_I diff_mean_I.fits diff_rms_I.fits 

