#!/bin/bash -l

#  sbatch -p workq pawsey_generate_beam.sh
#   ADDED : #SBATCH --cpus-per-gpu=1 
#     to enable using gpuq which is under-utlised on Garrawarla

# Generate beam images (FITS files) for each 1-second snapshot image

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem=120gb
#SBATCH --output=./smart_generate_beam.o%j
#SBATCH --error=./smart_generate_beam.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

# WARNING : this should realy be later in the code, but need it here to be used in the ls in the next line:
obsid=1276619416
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid="$1"
fi

timestamp_file="timestamps.txt"
if [[ -n "$2" && "$2" != "-" ]]; then
   timestamp_file="$2"
fi

postfix="_briggs-XX-image"
if [[ -n "$3" && "$3" != "-" ]]; then
   postfix="$3"
fi

freq_ch=145
if [[ -n "$4" && "$4" != "-" ]]; then
   freq_ch="$4"
fi

beam_step=60
if [[ -n "$5" && "$5" != "-" ]]; then
   beam_step=$5
fi


echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "obsid   = $obsid"
echo "timestamp_file  = $timestamp_file"
echo "postfix = $postfix"
echo "freq_ch = $freq_ch"
echo "beam_step = $beam_step"
echo "################################"

date

index=0
last_beam_image=""
for timestamp in `cat ${timestamp_file}`
do
   echo
   echo
   pwd
   cd $timestamp
   pwd
   pwd
   echo "Index = $index"

   image_fits=wsclean_${obsid}_${timestamp}${postfix}.fits

   # wsclean_1276619416_20200619163000_briggs-XX-image_beamXX.fits
   beam_fits_xx=wsclean_${obsid}_${timestamp}${postfix}_beamXX.fits
   beam_fits_yy=wsclean_${obsid}_${timestamp}${postfix}_beamYY.fits
   # beam_fits_i=wsclean_${obsid}_${timestamp}${postfix}_beamI.fits
   beam_fits_i=beamI.fits
   
   if [[ -s ${beam_fits_i} ]]; then
      echo "Primary beam FITS files already exist:"
      ls -al wsclean_${obsid}_${timestamp}${postfix}_beam*.fits $beam_fits_i

      last_beam_image=`pwd`/beamI.fits
      echo "last_beam_image = $last_beam_image"
   else   
      rest=$((index % $beam_step))
      echo "Index = $index -> rest = $rest"
      
      if [[ $rest == 0 ]]; then         
         echo "Primary beam FITS files do not exist -> generating now (rest = $rest)..."
         date
         ux_start=`date +%s`
         echo "python ~/github//mwa_pb/scripts/make_beam_test.py -f $image_fits -m ${timestamp}.metafits --model=2016 --obsid=${obsid} --freq_cc=${freq_ch}"
         python ~/github//mwa_pb/scripts/make_beam_test.py -f $image_fits -m ${timestamp}.metafits --model=2016 --obsid=${obsid} --freq_cc=${freq_ch}
         ux_end=`date +%s`
         ux_diff=$(($ux_end-$ux_start))
         echo "$ux_diff" > beam_benchmarking.txt 
         date
      
         ls ${beam_fits_xx} ${beam_fits_yy} > beam.list
      
         echo "avg_images beam.list ${beam_fits_i} out_rms.fits"
         avg_images beam.list ${beam_fits_i} out_rms.fits 
      
         echo "rm -f out_rms.fits"
         rm -f out_rms.fits
         
         last_beam_image=`pwd`/beamI.fits
         echo "last_beam_image = $last_beam_image"
      else
         echo "INFO : rest=$rest , linking previous beam model"
                  
         echo "ln -sf $last_beam_image"
         ln -sf $last_beam_image
      fi
   fi
   
   cd ..   
   
   index=$(($index+1))
done

date

echo "cat ${subdir}/beam_bench* > beam_benchmarking.txt"
cat ${subdir}/beam_bench* > beam_benchmarking.txt
