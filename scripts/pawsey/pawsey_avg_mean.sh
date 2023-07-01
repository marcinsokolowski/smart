#!/bin/bash -l

#  sbatch -p workq pawsey_smarter_avg_images.sh

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=120gb
#SBATCH --output=./smart_avgimages.o%j
#SBATCH --error=./smart_avgimages.e%j
#SBATCH --export=NONE

echo "module load msfitslib"
module load msfitslib

echo "INFO : using avg_images program from:"
which avg_images

# WARNING : this should realy be later in the code, but need it here to be used in the ls in the next line:
obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

subdir="20200522??????"
if [[ -n "$2" && "$2" != "-" ]]; then
   subdir="$2"
fi

outdir=avg/
if [[ -n "$3" && "$3" != "-" ]]; then
   outdir=$3
fi

force=0
max_rms=100000000000.00

date
pwd
mkdir -p ${outdir}
# average all images :
for pol in `echo "XX YY I"`
do
   echo "ls ${subdir}/mean_stokes_${pol}.fits > mean_fits_list_${pol}"
   ls ${subdir}/mean_stokes_${pol}.fits > mean_fits_list_${pol}
   
   echo "time avg_images mean_fits_list_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -i > ${outdir}/avg_${pol}.out 2>&1"
   time avg_images mean_fits_list_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -i > ${outdir}/avg_${pol}.out 2>&1 
done
date


# benchmarks :
# echo "cat ${subdir}/bench* > benchmarking.txt"
# cat ${subdir}/bench* > benchmarking.txt
