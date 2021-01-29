#!/bin/bash -l

# STARTING : sbatch -p workq -M magnus pawsey_manual_test.sh

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=16gb
#SBATCH --output=./test.o%j
#SBATCH --error=./test.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/magnus/env

# -norfi
cotter -absmem 64 -j 12 -timeres 1 -freqres 0.01 -edgewidth 80 -noflagautos  -m 20200601224229.metafits -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -full-apply 1275085504.bin -o 1275085816_20200601224229.ms 1275085816_20200601224229*gpubox*.fits

casapy --nologger -c flag_files.py

# applysolutions 1275085816_20200601224229.ms 1275085504.bin

/group/mwa/software/wsclean/wsclean2.6-112-gefc7f07/magnus/bin/wsclean -name wsclean_1275085816_20200601224229_briggs -j 6 -size 2048 2048  -pol XX,YY,XY,YX -abs-mem 64 -weight briggs -1 -scale 0.0056 -nmiter 1 -niter 10000 -threshold 0.050 -mgain 0.85 -minuv-l 30 -joinpolarizations 1275085816_20200601224229.ms 

