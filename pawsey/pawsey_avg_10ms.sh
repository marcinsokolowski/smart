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

for t in `ls -d ${subdir}`
do
   cd ${t}
   pwd
   date

   if [[ $rm_image -gt 0 ]]; then
      echo "rm -f *-image.fits"
      rm -f *-image.fits
   fi

   # average XX to YY
   for xx_fits in `ls wsclean_${obsid}_${t}_briggs_timeindex???-XX-dirty.fits`
   do
      yy_fits=${xx_fits%%-XX-dirty.fits}-YY-dirty.fits
      i_fits=${xx_fits%%-XX-dirty.fits}-I-dirty.fits
      
      ls $xx_fits $yy_fits > fits_list_xxyy
      echo "avg_images fits_list_xxyy ${i_fits} tmprms.out -r ${max_rms} > avg_xxyy.out 2>&1"
      avg_images fits_list_xxyy ${i_fits} tmprms.out -r ${max_rms} > avg_xxyy.out 2>&1
   done
      
   for pol in `echo "XX YY I"`
   do
      echo "ls wsclean_${obsid}_${t}_briggs_timeindex???-${pol}-dirty.fits > fits_list_${pol}"
      ls wsclean_${obsid}_${t}_briggs_timeindex???-${pol}-dirty.fits > fits_list_${pol}
   
      echo "time avg_images fits_list_${pol} mean_stokes_${pol}.fits rms_stokes_${pol}.fits -r ${max_rms} -i > avg_${pol}.out 2>&1"
      time avg_images fits_list_${pol} mean_stokes_${pol}.fits rms_stokes_${pol}.fits -r ${max_rms} -i > avg_${pol}.out 2>&1                  
   done
   
   # average X and Y to pseudo-stokes-I
   # ls mean_stokes_XX.fits mean_stokes_YY.fits > fits_list_XXYY
   # echo "avg_images fits_list_XXYY mean_stokes_I.fits rms_stokes_I.fits -r ${max_rms} > avg_XXYY.out 2>&1"
   # avg_images fits_list_XXYY mean_stokes_I.fits rms_stokes_I.fits -r ${max_rms} > avg_XXYY.out 2>&1 
   
   cd ../       
done

date
pwd
mkdir -p ${outdir}
# average all images :
for pol in `echo "XX YY I"`
do
   ls ${subdir}/mean_stokes_${pol}.fits > fits_list_${pol}
   
   echo "time avg_images fits_list_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -i > ${outdir}/avg_${pol}.out 2>&1"
   time avg_images fits_list_${pol} ${outdir}/mean_stokes_${pol}.fits ${outdir}/rms_stokes_${pol}.fits -r ${max_rms} -i > ${outdir}/avg_${pol}.out 2>&1 
done


# calculate RMS 
# cd ${outdir}
# ls *.fits > fits_list
# echo "sbatch -p workq pawsey_rms_test.sh"
# sbatch -p workq pawsey_rms_test.sh 
# cd -

# benchmarks :
echo "cat ${subdir}/bench* > benchmarking.txt"
cat ${subdir}/bench* > benchmarking.txt
