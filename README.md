# smart
Scripts for imaging offline correlated MWA VCS data in 1-second time resolution in order to look for pulsar candidates in image domain.

# example exection :
 Prepare metafits files for obsID = 1278106408 using calibration observation 1278106288

  cd /processing/dir/

 sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh 1278106408

# Test run of only timestamps listed in file timestamps_test.txt

  submit_all_magnus.sh 1278106408 1278106288 "00h34m08.9s -07d21m53.4s" - timestamps_test.txt

 
  Process all timestmaps :
 
  submit_all_magnus.sh 1278106408 1278106288 "00h34m08.9s -07d21m53.4s"

 
# Averaging (if not done automatically) :

  sbatch -p workq -M garrawarla /home/susmita/smart//bin/pawsey/pawsey_avg_images.sh

# if you decide to use these scripts for your research please acknowledge this by citing this paper:

Sett et al., "Image-based searches for pulsar candidates using MWA VCS data ", Publications of the Astronomical Society of Australia, Volume 40, article id. e003
(https://ui.adsabs.harvard.edu/abs/2023PASA...40....3S/abstract)
