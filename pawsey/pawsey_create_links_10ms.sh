#!/bin/bash

#  sbatch -p workq pawsey_create_links_10ms.sh

# Create symbolic links are required by create_dynaspec program 

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=1gb
#SBATCH --output=./pawsey_create_links_10ms.o%j
#SBATCH --error=./pawsey_create_links_10ms.e%j
#SBATCH --export=NONE


template="20200522??????"

time10ms_index=0

# wsclean_1274143152_20200522003856_briggs_timeindex001-0000-I-dirty.fits
# wsclean_timeindex00000000/wsclean_1274143152_timeindex000-0000-I-dirty.fits
for t_sec in `ls -d ${template}`
do
   t_subidx=0
   while [[ $t_subidx -lt 100 ]];
   do
      t_str=`echo $time10ms_index | awk '{printf("%04d",$1);}'`      
      t_subidx_str=`echo $t_subidx | awk '{printf("%03d",$1);}'`
      
      subdir=wsclean_timeindex${t_str}
      mkdir -p ${subdir}
      cd ${subdir}
      pwd
      echo "DEBUG : ../${t_sec}/wsclean_1274143152_${t_sec}_briggs_timeindex${t_subidx_str}-*-I-dirty.fits"
      # wsclean_1274143152_timeindex${t_subidx_str}-*-I-dirty.fits
      for fits in `ls ../${t_sec}/wsclean_1274143152_${t_sec}_briggs_timeindex${t_subidx_str}-*-I-dirty.fits`
      do
         # wsclean_1274143152_timeindex${t_subidx_str}-*-I-dirty.fits
         b_fits=`basename $fits`
         ch_str=`echo $b_fits | cut -b 55-58`
         echo "DEBUG : $fits -> $b_fits -> ch_str = $ch_str"

# was :         
#         echo "   ln -sf ${fits} wsclean_1274143152_timeindex${t_subidx_str}-${ch_str}-I-dirty.fits"
#         ln -sf ${fits} wsclean_1274143152_timeindex${t_subidx_str}-${ch_str}-I-dirty.fits
         echo "ln -sf ${fits} wsclean_1274143152_timeindex${t_str}-${ch_str}-I-dirty.fits"
         ln -sf ${fits} wsclean_1274143152_timeindex${t_str}-${ch_str}-I-dirty.fits
      done
      
      cd ..
      
      t_subidx=$(($t_subidx+1))
      time10ms_index=$(($time10ms_index+1))
   done   
done
