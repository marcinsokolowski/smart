"""
Script to calibrate with a custom cal table
Tim Colegate, 22/09/14

Input: caltable
Output: calibrated CASA measurement set
"""

import sys,optparse
import re

# create command line arguments
parser=optparse.OptionParser()
parser.set_usage("Usage: casapy -c apply_custom_cal.py <target_ms.ms> <cal_table.cal>")

# parse command line arguments
casa_index=sys.argv.index('-c')+2  # remove CASA options
(options,args)=parser.parse_args(sys.argv[casa_index:])
input_ms=args[-2]  # calibrated CASA measurement set
cal_name=args[-1]

print 'Applying cal table %s to target ms %s'%(cal_name,input_ms)
# --- APPLYCAL - Apply calibration to .ms set, putting calibrated visibilities into CORRECTED_DATA column
applycal (vis=input_ms, gaintable=cal_name) 
