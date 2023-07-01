#!/bin/bash

export DISPLAY=:0

calid=1255443816
calname=3C444

datadir=~/D0005/msok/asvo/202002/${calid}
smart_bin=$SMART_DIR/bin/

cd ${datadir}
echo "obs_id=${calid}, job_type=c, download_type=vis, timeres=4, freqres=40, conversion=ms, edgewidth=80, allowmissing=true, noflagautos=true" > request.csv
mwa_client --csv=request.csv --dir=./

echo "unzip *.zip"
unzip *.zip

echo "casapy -c ${smart_bin}/ft_beam_cal_only_nodb.py ${calname} ~/calibrators/VLSSr_NVSS/ ${calid}.ms"
casapy -c ${smart_bin}/ft_beam_cal_only_nodb.py ${calname} ~/calibrators/VLSSr_NVSS/ ${calid}.ms

echo "casapy -c ${smart_bin}/apply_custom_cal.py ${calid}.ms ${calid}.cal"
casapy -c ${smart_bin}/apply_custom_cal.py ${calid}.ms ${calid}.cal

echo "casapy -c ${smart_bin}/image_tile_auto.py --imagesize=1024 ${calid}.ms"
casapy -c ${smart_bin}/image_tile_auto.py --imagesize=1024 ${calid}.ms


echo "~/bin/plotcal! ${calid}"
~/bin/plotcal! ${calid}

