# smart
Scripts for processing MWA VCS data 

# example exection :
# Prepare metafits files for obsID = 1278106408 using calibration observation 1278106288
# cd /processing/dir/
# sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh 1278106408
#
# Test run of only timestamps listed in file timestamps_test.txt
# submit_all_magnus.sh 1278106408 1278106288 "00h34m08.9s -07d21m53.4s" - timestamps_test.txt
# 
# Process all timestmaps :
# submit_all_magnus.sh 1278106408 1278106288 "00h34m08.9s -07d21m53.4s"
# 
# Averaging (if not done automatically) :
# sbatch -p workq -M garrawarla /home/susmita/smart//bin/pawsey/pawsey_avg_images.sh
