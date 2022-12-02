#!/bin/bash -l

# pawsey_avg_fitslist.sh to average a specified list of FITS files 

#SBATCH --account=mwavcs
#SBATCH --time=23:59:59
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=16gb
#SBATCH --output=./pawsey_avg_fitslist.o%j
#SBATCH --error=./pawsey_avg_fitslist.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/magnus/env


fits_list=avg.list
if [[ -n "$1" && "$1" != "-" ]]; then
   fits_list=$1
fi

# (12.14 - 4.02 - 6*1.306)*100 = 28.400 ~= 28 
# see ./pulse_time_index.py
start_timeindex=28.4
if [[ -n "$2" && "$2" != "-" ]]; then
   start_timeindex=$2
fi
start_timeindex_str=`echo $start_timeindex | awk '{printf("%05d\n",$1);}'`

outdir="avg${start_timeindex_str}/"
if [[ -n "$3" && "$3" != "-" ]]; then
   outdir="$3"
fi

copy_and_remove=1
if [[ -n "$4" && "$4" != "-" ]]; then
   copy_and_remove=$4
fi

echo "pawsey_generate_image_list.sh ${start_timeindex}"
pawsey_generate_image_list.sh ${start_timeindex}

max_rms=100000000

mkdir -p ${outdir}

echo "time avg_images ${fits_list} ${outdir}/mean.fits ${outdir}/rms.fits -r ${max_rms} > ${outdir}/avg_${stokes}.out 2>&1"
time avg_images ${fits_list} ${outdir}/mean.fits ${outdir}/rms.fits -r ${max_rms} > ${outdir}/avg_${stokes}.out 2>&1                     

if [[ $copy_and_remove -gt 0 ]]; then
   echo "rsync -avP ${outdir} topaz:/group/mwavcs/msok/astro/1274143152/10ms/24channels/"
   rsync -avP ${outdir} topaz:/group/mwavcs/msok/astro/1274143152/10ms/24channels/

   echo "rm -fr /tmp/avg/"
   rm -fr /tmp/avg/
fi
