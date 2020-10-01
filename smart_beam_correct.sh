#!/bin/bash


# msok@mwa-process02:~/D0005/msok/asvo/202002/1150234232/data/full_data_set/Candidate
# python ~/github/mwa_pb/scripts/beam_correct_image.py --xx_file=wsclean_1150234552_20160617222703_briggs-XX-image.fits --yy_file=wsclean_1150234552_20160617222703_briggs-YY-image.fits  --xy_file=wsclean_1150234552_20160617222703_briggs-XY-image.fits --xyi_file=wsclean_1150234552_20160617222703_briggs-XYi-image.fits --metafits 20160617222705.metafits -model=2016

# wsclean_1150234552_20160617222703_briggs-XX-image.fits
for fits_xx in `cat fits_list_xx`
do
   fits_yy=`echo $fits_xx | awk '{gsub("-XX-","-YY-",$1);print $1;}'`
   fits_xy=`echo $fits_xx | awk '{gsub("-XX-","-XY-",$1);print $1;}'`
   fits_xyi=`echo $fits_xx | awk '{gsub("-XX-","-XYi-",$1);print $1;}'`
   bname=${fits_xx%%-XX-image.fits}
   dtm=`echo $fits_xx | awk -F "_" '{print $3;}'`

   echo "Started at :"
   date      
   echo "time python ~/github/mwa_pb/scripts/beam_correct_image.py --xx_file=${fits_xx} --yy_file=${fits_yy} --xy_file=${fits_xy} --xyi_file=${fits_xyi} --metafits ${dtm}.metafits --model=2016 --out_basename=${bname}-image"
   time python ~/github/mwa_pb/scripts/beam_correct_image.py --xx_file=${fits_xx} --yy_file=${fits_yy} --xy_file=${fits_xy} --xyi_file=${fits_xyi} --metafits ${dtm}.metafits --model=2016 --out_basename=${bname}-image
   
   echo "Finished at :"
   date
done


for stokes in `echo "I Q U V"`
do
   ls wsclean*-image_${stokes}.fits > fits_stokes_${stokes}
   
   
   echo "avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits"
   avg_images fits_stokes_${stokes} mean_stokes_${stokes}.fits rms_stokes_${stokes}.fits 
done





