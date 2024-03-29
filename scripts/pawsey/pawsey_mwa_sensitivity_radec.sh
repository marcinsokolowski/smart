#!/bin/bash -l

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
#SBATCH --tasks-per-node=8
#SBATCH --mem=20gb
#SBATCH --output=./pawsey_mwa_sensitivity_radec.o%j
#SBATCH --error=./pawsey_mwa_sensitivity_radec.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env
module load skyfield

obsid=1276622116
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

ra=276.68
if [[ -n "$2" && "$2" != "-" ]]; then
   ra=$2
fi

dec=-5.68
if [[ -n "$3" && "$3" != "-" ]]; then
   dec=$3
fi

freq_cc=145
if [[ -n "$4" && "$4" != "-" ]]; then
   freq_cc=$4   
fi

gpstime_start=$obsid
if [[ -n "$5" && "$5" != "-" ]]; then
   gpstime_start=$5
fi

inttime=1
if [[ -n "$6" && "$6" != "-" ]]; then
   inttime=$6
fi

duration=5400
if [[ -n "$7" && "$7" != "-" ]]; then
   duration=$7
fi


echo "##########################################################################"
echo "PARAMETERS :"
echo "##########################################################################"
echo "obsid             = $obsid"
echo "(ra,dec)          = ($ra,$dec) [deg]"
echo "Frequency channel = $freq_cc"
echo "gpstime_start     = $gpstime_start"
echo "duration          = $duration"
echo "inttime           = $inttime [sec]"
echo "##########################################################################"


pwd
if [[ ! -s ${obsid}.metafits ]]; then
   url="http://ws.mwatelescope.org/metadata/fits?obs_id="
   echo "wget ${url}${obsid} -O ${obsid}.metafits"
   wget ${url}${obsid} -O ${obsid}.metafits
else
   echo "INFO : metafits file ${obsid}.metafits already exists"
fi

echo "python ~/github/mwa_pb/scripts/mwa_sensitivity.py -g ${gpstime_start} -m full_EE --freq_cc ${freq_cc} --metafits ${obsid}.metafits --inttime=${inttime} --bandwidth=30720000 --ra=${ra} --dec=${dec} --dec=${dec} --observation_duration=${duration}"
python ~/github/mwa_pb/scripts/mwa_sensitivity.py -g ${gpstime_start} -m full_EE --freq_cc ${freq_cc} --metafits ${obsid}.metafits --inttime=${inttime} --bandwidth=30720000 --ra=${ra} --dec=${dec} --observation_duration=${duration}
