#!/bin/bash

obsid=1150234552
ms=1150234552_20160617213542.ms
if [[ -n "$1" && "$1" != "-" ]]; then
    ms=$1
fi
obsid=`echo $ms | cut -b 1-10`
metafits_base=`echo $ms | cut -b 12-25`
ms_b=${ms%%.ms}

options=""
n_iter=10000
if [[ -n "$2" && "$2" != "-" ]]; then
   n_iter=$2
fi

do_casa=0
if [[ -n "$3" && "$3" != "-" ]]; then
   do_casa=$3
fi

beam_corr_type="image"
if [[ -n "$4" && "$4" != "-" ]]; then
   beam_corr_type=$4
fi

clean_thresh=0.3

if [[ $n_iter -gt 0 ]]; then
   options="-joinpolarizations"
fi

imagesize=2048
if [[ -n "$5" && "$5" != "-" ]]; then
   imagesize=$5
fi

special_python_path=`which python`
# chgcentre_path=""
comp=`hostname`
if [[ $comp == "mwa-process02" ]]; then
   # specific for mwa-process02
   # chgcentre_path="/home/msok/mwa_software/anoko/anoko/chgcentre/build/"
   special_python_path=~/anaconda/bin/python
#    export PATH=/home/msok/mwa_software/anoko/anoko/chgcentre/build/:$PATH
fi


NCPUS=4

metafits=${metafits_base}.metafits
metainfo=${metafits%%metafits}metadata_info
url="http://ws.mwatelescope.org/metadata/fits?obs_id="

if [[ -s $metafits ]]; then
   echo "Metafits file $metafits found -> nothing to be done"
else
   echo "WARNING : metafits file $metafits does not exist -> getting ..."

   echo "wget ${url}${obsid} -O ${obsid}.metafits"
   wget ${url}${obsid} -O ${obsid}.metafits
fi

path=$SMART_DIR/bin/metadata_auto.py
echo "$special_python_path $path ${metafits} --all"
$special_python_path $path ${metafits} --all

n_scans=592
inttime=0.5
max_baseline_int=-1
pixscale=0.08

if [[ -s $metainfo ]]; then
   echo "OK : file $metainfo exists -> continuing processing"   
   
   n_scans=`grep N_SCANS $metainfo | awk '{print $3;}'`
   inttime=`grep INTTIME $metainfo | awk '{print $3;}'`
   max_baseline=`grep MAX_BASELINE $metainfo | awk '{print $3;}'`
   max_baseline_int=`echo $max_baseline | awk '{printf("%d",$1);}'`
   pixscale=`cat $metainfo | grep PIXSCALE | awk '{print $6}'`
   
   echo "Extracted metadata :"
   echo "   n_scans      = $n_scans"
   echo "   inttime      = $inttime"
   echo "   max_baseline_int = $max_baseline_int"
   echo "   pixscale     = $pixscale"
else
   echo "ERROR : file $metainfo not created -> cannot continue"
   exit -2;
fi

echo "------------------------------------------------------------"
echo "cat ${metainfo}"
cat ${metainfo}
echo "------------------------------------------------------------"



# old 
# echo "wsclean -name wsclean_${obsid} -j $NCPUS -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -abs-mem 64 -weight briggs -1 -scale $pixscale -niter ${n_iter} ${options} ${ms}"
# wsclean -name wsclean_${obsid} -j $NCPUS -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -abs-mem 64 -weight briggs -1 -scale $pixscale -niter ${n_iter} ${options} ${ms}

# if [[ $obsnum -gt 1219795217 ]]; then
if [[ $max_baseline_int -lt 2800 ]]; then # 20190309 - changed for a proper condition 
    # gps >= 20180901_000000 1219795217  -> compact configuration 
    # log : wsclean_${b}_timeindex${time_index}.out
    # removed : -minuv-l 30
    # echo "GPS time > 1219795217 ( 20180901_000000 ) -> using COMPACT CONFIGURATION SETTINGS"
    echo "max_baseline_int = $max_baseline_int < 2800 -> using COMPACT CONFIGURATION SETTINGS"
    
    echo "wsclean -name wsclean_${ms_b}_briggs -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight briggs -1 -scale $pixscale -niter ${n_iter} -threshold ${clean_thresh} ${options} ${ms}"
    wsclean -name wsclean_${ms_b}_briggs -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight briggs -1 -scale $pixscale -niter ${n_iter} -threshold ${clean_thresh} ${options} ${ms}
else
    # GPS time <= 1219795217 ( 20180901_000000 ) -> using LONG-BASELINES SETTINGS"
    echo "max_baseline_int = $max_baseline_int >= 2800 -> using LONG-BASELINES SETTINGS"

    # gps <= 20180901_000000 1219795217  -> compact configuration 
    # removed : -minuv-l 30
#    echo "wsclean -name wsclean_${obsid}_natural -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale $pixscale -niter ${n_iter} ${options} ${ms}"
#    wsclean -name wsclean_${obsid}_natural -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale $pixscale -niter ${n_iter} ${options} ${ms}

#    echo "wsclean -name wsclean_${obsid}_uniform -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight uniform -scale $pixscale -niter ${n_iter} ${options} ${ms}"
#    wsclean -name wsclean_${obsid}_uniform -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight uniform -scale $pixscale -niter ${n_iter} ${options} ${ms}

    echo "wsclean -name wsclean_${ms_b}_briggs -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight briggs -1 -scale $pixscale -niter ${n_iter} -threshold ${clean_thresh} ${options} ${ms}"
    wsclean -name wsclean_${ms_b}_briggs -j 6 -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight briggs -1 -scale $pixscale -niter ${n_iter} -threshold ${clean_thresh} ${options} ${ms}
fi    

fits_xx=wsclean_${ms_b}_briggs-XX-${beam_corr_type}.fits
fits_yy=wsclean_${ms_b}_briggs-YY-${beam_corr_type}.fits
fits_xy=wsclean_${ms_b}_briggs-XY-${beam_corr_type}.fits
fits_xyi=wsclean_${ms_b}_briggs-XYi-${beam_corr_type}.fits
bname=wsclean_${ms_b}_briggs

echo "time python ~/github/mwa_pb/scripts/beam_correct_image.py --xx_file=${fits_xx} --yy_file=${fits_yy} --xy_file=${fits_xy} --xyi_file=${fits_xyi} --metafits ${metafits} --model=2016 --out_basename=${bname}-${beam_corr_type}"
time python ~/github/mwa_pb/scripts/beam_correct_image.py --xx_file=${fits_xx} --yy_file=${fits_yy} --xy_file=${fits_xy} --xyi_file=${fits_xyi} --metafits ${metafits} --model=2016 --out_basename=${bname}-${beam_corr_type}


# long baselines :
# wsclean -name wsclean_${obsid} -j $NCPUS -size ${imagesize} ${imagesize}  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale $pixscale -interval ${time_index} ${time_index2} ${options} ${ms}


if [[ $do_casa -gt 0 ]]; then
   if [[ ! -s ./image_tile_auto.py ]]; then
      echo "cp $SMART_DIR/image_tile_auto.py ."
      cp $SMART_DIR/image_tile_auto.py .   
   fi

   echo "casapy --nogui --nologger -c ./image_tile_auto.py --imagesize=1024 --pols=XX,YY ${ms}"
   casapy --nogui --nologger -c ./image_tile_auto.py --imagesize=1024 --pols=XX,YY ${ms}
   
   echo "python $SMART_DIR/bin/fixCoordHdr.py ${ms}*_XX_*.fits"
   python $SMART_DIR/bin/fixCoordHdr.py ${ms}*_XX_*.fits

   echo "python $SMART_DIR/bin/fixCoordHdr.py ${ms}*_YY_*.fits"
   python $SMART_DIR/bin/fixCoordHdr.py ${ms}*_YY_*.fits
else
   echo "WARNING : CASA image is not required"
fi   
