#!/opt/caastro/ext/anaconda/bin/python

import astropy.io.fits as pyfits
import pylab
import math 
from array import *
import matplotlib.pyplot as plt
import numpy as np
import string
import sys
import os
import errno
import getopt
import optparse


# global parameters :
debug=0
fitsname="file.fits"
out_fitsname="scaled.fits"
do_show_plots=0
do_gif=0

center_x=1025
center_y=1025
radius=600

def mkdir_p(path):
   try:
      os.makedirs(path)
   except OSError as exc: # Python >2.5
      if exc.errno == errno.EEXIST:
         pass
      else: raise
                                            
def usage():
   print "set_keyword.py FITS_FILE FREQ" % out_fitsname
   print "\n"
   print "-d : increases verbose level"
   print "-h : prints help and exists"
   print "-g : produce gif of (channel-avg) for all integrations"

# functions :
def parse_command_line():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hvdg", ["help", "verb", "debug", "gif"])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ("-d","--debug"):
            debug += 1
        if o in ("-v","--verb"):
            debug += 1
        if o in ("-g","--gif"):
            do_gif = 1
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
    # ...

# 
if len(sys.argv) > 1:
   fitsname = sys.argv[1]

keyword='TEST'
if len(sys.argv) > 2:
   keyword = sys.argv[2]

value='VALUE'
if len(sys.argv) > 3:
   value = sys.argv[3]

parser=optparse.OptionParser()
parser.set_usage("""setkey.py""")
parser.add_option('-i','--int','--integer',action="store_true",dest="integer",default=False, help="Integer ?")
parser.add_option('-f','--float','--float',action="store_true",dest="float",default=False, help="Float ?")
# parser.add_option("--ap_radius","-a","--aperture","--aperture_radius",dest="aperture_radius",default=0,help="Sum pixels in aperture radius [default: %default]",type="int")
# parser.add_option("--verbose","-v","--verb",dest="verbose",default=0,help="Verbosity level [default: %default]",type="int")
# parser.add_option("--outfile","-o",dest="outfile",default=None,help="Output file name [default:]",type="string")
# parser.add_option('--use_max_flux','--use_max_peak_flux','--max_flux',dest="use_max_peak_flux",action="store_true",default=False, help="Use maximum flux value around the source center [default %]")
(options,args)=parser.parse_args(sys.argv[4:])


print "####################################################"
print "PARAMTERS :"
print "####################################################"
print "fitsname       = %s"   % fitsname
print "SET %s := %s" % (keyword,value)
print "integer = %s" % (options.integer)
print "float   = %s" % (options.float)
print "####################################################"

fits_list=["1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0000.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0001.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0002.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0003.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0004.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0005.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0006.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0007.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0008.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0009.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0010.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0011.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0012.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0013.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0014.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0015.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0016.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0017.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0018.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0019.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0020.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0021.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0022.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0023.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0024.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0025.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0026.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0027.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0028.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0029.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0030.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0031.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0032.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0033.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0034.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0035.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0036.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0037.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0038.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0039.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0040.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0041.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0042.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0043.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0044.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0045.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0046.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0047.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0048.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0049.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0050.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0051.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0052.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0053.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0054.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0055.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0056.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0057.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0058.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0059.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0060.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0061.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0062.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0063.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0064.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0065.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0066.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0067.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0068.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0069.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0070.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0071.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0072.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0073.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0074.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0075.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0076.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0077.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0078.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0079.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0080.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0081.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0082.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0083.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0084.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0085.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0086.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0087.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0088.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0089.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0090.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0091.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0092.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0093.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0094.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0095.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0096.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0097.fits","1150234552.ms_briggs-1_TH300mJy_CF10_clark__I_0.52arcmin_2048px_UV_niter10000_timeindex0098.fits"]
timerange_ranges = [ "2016-06-17T21:35:44","2016-06-17T21:35:48","2016-06-17T21:35:52","2016-06-17T21:35:56","2016-06-17T21:36:00","2016-06-17T21:36:04","2016-06-17T21:36:08","2016-06-17T21:36:12","2016-06-17T21:36:16","2016-06-17T21:36:20","2016-06-17T21:36:24","2016-06-17T21:36:28","2016-06-17T21:36:32","2016-06-17T21:36:36","2016-06-17T21:36:40","2016-06-17T21:36:44","2016-06-17T21:36:48","2016-06-17T21:36:52","2016-06-17T21:36:56","2016-06-17T21:37:00","2016-06-17T21:37:04","2016-06-17T21:37:08","2016-06-17T21:37:12","2016-06-17T21:37:16","2016-06-17T21:37:20","2016-06-17T21:37:24","2016-06-17T21:37:28","2016-06-17T21:37:32","2016-06-17T21:37:36","2016-06-17T21:37:40","2016-06-17T21:37:44","2016-06-17T21:37:48","2016-06-17T21:37:52","2016-06-17T21:37:56","2016-06-17T21:38:00","2016-06-17T21:38:04","2016-06-17T21:38:08","2016-06-17T21:38:12","2016-06-17T21:38:16","2016-06-17T21:38:20","2016-06-17T21:38:24","2016-06-17T21:38:28","2016-06-17T21:38:32","2016-06-17T21:38:36","2016-06-17T21:38:40","2016-06-17T21:38:44","2016-06-17T21:38:48","2016-06-17T21:38:52","2016-06-17T21:38:56","2016-06-17T21:39:00","2016-06-17T21:39:04","2016-06-17T21:39:08","2016-06-17T21:39:12","2016-06-17T21:39:16","2016-06-17T21:39:20","2016-06-17T21:39:24","2016-06-17T21:39:28","2016-06-17T21:39:32","2016-06-17T21:39:36","2016-06-17T21:39:40","2016-06-17T21:39:44","2016-06-17T21:39:48","2016-06-17T21:39:52","2016-06-17T21:39:56","2016-06-17T21:40:00","2016-06-17T21:40:04","2016-06-17T21:40:08","2016-06-17T21:40:12","2016-06-17T21:40:16","2016-06-17T21:40:20","2016-06-17T21:40:24","2016-06-17T21:40:28","2016-06-17T21:40:32","2016-06-17T21:40:36","2016-06-17T21:40:40","2016-06-17T21:40:44","2016-06-17T21:40:48","2016-06-17T21:40:52","2016-06-17T21:40:56","2016-06-17T21:41:00","2016-06-17T21:41:04","2016-06-17T21:41:08","2016-06-17T21:41:12","2016-06-17T21:41:16","2016-06-17T21:41:20","2016-06-17T21:41:24","2016-06-17T21:41:28","2016-06-17T21:41:32","2016-06-17T21:41:36","2016-06-17T21:41:40","2016-06-17T21:41:44","2016-06-17T21:41:48","2016-06-17T21:41:52","2016-06-17T21:41:56","2016-06-17T21:42:00","2016-06-17T21:42:04","2016-06-17T21:42:08","2016-06-17T21:42:12","2016-06-17T21:42:16"]

print "len(fits_list) = %d" % (len(fits_list))
print "len(timerange_ranges) = %d" % (len(timerange_ranges))

if len(fits_list) != len(timerange_ranges) :
   print "ERROR : different lengths !!!"
   exit(-1)
   


i=0
for fitsname in fits_list :
   dateobs=timerange_ranges[i]
   fits = pyfits.open(fitsname)
   fits[0].header['DATE-OBS'] = dateobs
   
   print "%s : DATE-OBS := %s" % (fitsname,dateobs)   
   print "Writing fits %s ..." % (fitsname)
   fits.writeto( fitsname, clobber=True ) 
   
   i = i +1 



