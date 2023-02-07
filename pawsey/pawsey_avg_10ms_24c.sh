#!/bin/bash -l

#  sbatch -p workq pawsey_avg_10ms.sh

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

avg_final=0
if [[ -n "$4" && "$4" != "-" ]]; then
   avg_final=$4
fi


force=0
max_rms=100000000000.00

for t in `ls -d ${subdir}`
do
   cd ${t}
   echo "Processing : ${t}"
   pwd
   date

   if [[ $rm_image -gt 0 ]]; then
      echo "rm -f *-image.fits"
      rm -f *-image.fits
   fi

   # average XX to YY   
#   for xx_fits in `ls wsclean_${obsid}_${t}_briggs_timeindex???-XX-dirty.fits`
   for xx_fits_ch0 in `ls wsclean_${obsid}_${t}_briggs_timeindex???-0000-XX-dirty.fits`
   do
      echo $xx_fits_ch0
   
      cc=0
      while [[ $cc -lt 24 ]];
      do
         echo "   cc=$cc"
         cc_str=`echo $cc | awk '{printf("%04d",$1);}'`
         xx_fits_cc=${xx_fits_ch0%%-0000-XX-dirty.fits}-${cc_str}-XX-dirty.fits
         yy_fits_cc=${xx_fits_ch0%%-0000-XX-dirty.fits}-${cc_str}-YY-dirty.fits 
         i_fits_cc=${xx_fits_ch0%%-0000-XX-dirty.fits}-${cc_str}-I-dirty.fits
         
         if [[ -s ${i_fits_cc} ]]; then       
            echo "   INFO : image $i_fits_cc already exists -> skipped"
         else
            echo "   ls $xx_fits_cc $yy_fits_cc > fits_list_xxyy"
            ls $xx_fits_cc $yy_fits_cc > fits_list_xxyy
            echo "   avg_images fits_list_xxyy ${i_fits_cc} tmprms.out -r ${max_rms} > avg_xxyy.out 2>&1"
            avg_images fits_list_xxyy ${i_fits_cc} tmprms.out -r ${max_rms} > avg_xxyy.out 2>&1
         fi
         
         cc=$(($cc+1))
      done
   done
      
   
   cd ../       
done

date
