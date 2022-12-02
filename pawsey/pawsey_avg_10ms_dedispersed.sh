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
if [[ -s $HOME/smart/bin/magnus/env ]]; then
   echo "source $HOME/smart/bin/magnus/env"
   source $HOME/smart/bin/magnus/env
fi   

# (12.14 - 4.02 - 6*1.306)*100 = 28.400 ~= 28 
# see ./pulse_time_index.py
start_timeindex=28.4
if [[ -n "$1" && "$1" != "-" ]]; then
   start_timeindex=$1
fi
start_timeindex_str=`echo $start_timeindex | awk '{printf("%05d\n",$1);}'`

outdir="avg${start_timeindex_str}"
if [[ -n "$2" && "$2" != "-" ]]; then
   outdir="$2"
fi

generate_list=1
if [[ -n "$3" && "$3" != "-" ]]; then
   generate_list=$3
fi

copy_and_remove=0
if [[ -n "$4" && "$4" != "-" ]]; then
   copy_and_remove=$4
fi

listfile=list_${start_timeindex_str}.txt
max_rms=100000000

mkdir -p ${outdir}

# echo "cp dispersed_path_dm20.870.txt ${outdir}/"
# cp dispersed_path_dm20.870.txt ${outdir}/
# cd ${outdir}

if [[ $generate_list -gt 0 ]]; then
   echo "pawsey_generate_image_list.sh ${start_timeindex} ${listfile}"
   pawsey_generate_image_list.sh ${start_timeindex} ${listfile}
else
   echo "WARNING : list generation is not required"
fi

echo "time avg_images ${listfile} ${outdir}/mean.fits ${outdir}/rms.fits -r ${max_rms} -i > ${outdir}/avg_${stokes}.out 2>&1"
time avg_images ${listfile} ${outdir}/mean.fits ${outdir}/rms.fits -r ${max_rms} -i > ${outdir}/avg_${stokes}.out 2>&1                     

if [[ $copy_and_remove -gt 0 ]]; then
#   echo "rsync -avP ${outdir} topaz:/group/mwavcs/msok/astro/1274143152/10ms/24channels/"
#   rsync -avP ${outdir} topaz:/group/mwavcs/msok/astro/1274143152/10ms/24channels/
   echo "rsync -avP ${outdir} 146.118.65.215:/data/mwa/"
   rsync -avP ${outdir} 146.118.65.215:/data/mwa/

   echo "rm -fr ${outdir}"
   rm -fr ${outdir}
fi
