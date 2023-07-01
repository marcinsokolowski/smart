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


echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "obsid   = $obsid"
echo "timestamp_file  = $timestamp_file"
echo "postfix = $postfix"
echo "freq_ch = $freq_ch"
echo "################################"

date

for timestamp in `cat ${timestamp_file}`
do
   echo
   echo
   cd $timestamp
   pwd

   image_fits=wsclean_${obsid}_${timestamp}${postfix}.fits

   # wsclean_1276619416_20200619163000_briggs-XX-image_beamXX.fits
   beam_fits=wsclean_${obsid}_${timestamp}${postfix}-beam-xxr.fits
   
   if [[ -s ${beam_fits} ]]; then
      echo "Primary beam FITS files already exist:"
      ls -al wsclean_${obsid}_${timestamp}${postfix}-beam*.fits
   else   
      echo "Primary beam FITS files do not exist -> generating now ..."
      date
      ux_start=`date +%s`
#      echo "python ~/github//mwa_pb/scripts/make_beam_test.py -f $image_fits -m ${timestamp}.metafits --model=2016 --obsid=${obsid} --freq_cc=${freq_ch}"
#      python ~/github//mwa_pb/scripts/make_beam_test.py -f $image_fits -m ${timestamp}.metafits --model=2016 --obsid=${obsid} --freq_cc=${freq_ch}

      # create link to HDF5 file 
      mkdir -p mwapy/
      cd mwapy
      ln -s ../data     
      cd ../      
      ls -al mwapy/data/mwa_full_embedded_element_pattern.h5
      
      echo "beam -2016 -square -proto ${image_fits} -m ${timestamp}.metafits -name wsclean_${obsid}_${timestamp}${postfix}-beam"
      beam -2016 -square -proto ${image_fits} -m ${timestamp}.metafits -name wsclean_${obsid}_${timestamp}${postfix}-beam
      
      ux_end=`date +%s`
      ux_diff=$(($ux_end-$ux_start))
      echo "$ux_diff" > beam_benchmarking.txt 
      date
   fi
   
   cd ..   
done

date

echo "cat ${subdir}/beam_bench* > beam_benchmarking.txt"
cat ${subdir}/beam_bench* > beam_benchmarking.txt
