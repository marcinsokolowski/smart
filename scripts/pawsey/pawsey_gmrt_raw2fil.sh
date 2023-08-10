#!/bin/bash -l

#SBATCH --account=mwavcs
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=32gb
#SBATCH --output=./pawsey_gmrt_raw2fil.o%j
#SBATCH --error=./pawsey_gmrt_raw2fil.e%j
#SBATCH --export=NONE

rawfile_base=J1857-1027_bm2_ia_500_200_64_13may2023
if [[ -n "$1" && "$1" != "-" ]]; then
   rawfile_base="$1"
fi

options="-u"
if [[ -n "$2" && "$2" != "-" ]]; then
   options="$2"
fi

rawfile=${rawfile_base}.raw
filheadfile=${rawfile_base}.fil.head
filfile=${rawfile_base}.fil

UGMRT_SOFT_PATH=/home/msok/github/ugmrt2fil/
export PATH=$UGMRT_SOFT_PATH:$PATH

#                                                  RAW_FILENAME                               OUTPUT_HEADER_FILE .fil.head            PSRNAME  MJD    FREQ[MHz] N_CHAN BW[MHz] TimeRes[sec?] sAME: OUTPUT_HEADER_FILE .fil.head
echo "${UGMRT_SOFT_PATH}/ugmrtfilhead ${rawfile} ${filheadfile} J1857-1027 1000.00 1000.00 32 100.00 0.01 ${filheadfile}"
${UGMRT_SOFT_PATH}/ugmrtfilhead ${rawfile} ${filheadfile} J1857-1027 1000.00 1000.00 32 100.00 0.01 ${filheadfile}

# TODO : update parameters and maybe add option -u for USB (vs. LSB!) - here:
# created .fil file :
echo "${UGMRT_SOFT_PATH}/ugmrt2fil -i ${rawfile} -o ${filfile}  -j J1857-1027 -d 1000.00 -f 1000.00 -c 32 -w 100.00 -t 0.001 ${options}"
${UGMRT_SOFT_PATH}/ugmrt2fil -i ${rawfile} -o ${filfile}  -j J1857-1027 -d 1000.00 -f 1000.00 -c 32 -w 100.00 -t 0.001 ${options}

