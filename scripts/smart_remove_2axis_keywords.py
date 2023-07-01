#!/opt/caastro/ext/anaconda/bin/python

from __future__ import print_function
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
   print("set_keyword.py FITS_FILE FREQ" % out_fitsname)
   print("\n")
   print("-d : increases verbose level")
   print("-h : prints help and exists")
   print("-g : produce gif of (channel-avg) for all integrations")

# functions :
def parse_command_line():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hvdg", ["help", "verb", "debug", "gif"])
    except getopt.GetoptError as err:
        # print help information and exit:
        print(str(err)) # will print something like "option -a not recognized"
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

freq_hz=0
if len(sys.argv) > 2:
   freq_hz = float(sys.argv[2])

deg2rad=math.pi/180.00
lat_deg=-26.703319
lat_radian=lat_deg*deg2rad
   
print("####################################################")
print("PARAMTERS :")
print("####################################################")
print("fitsname       = %s"   % fitsname)
print("freq           = %d [Hz]" % freq_hz)
print("####################################################")

fits = pyfits.open(fitsname)
x_size=fits[0].header['NAXIS1']
# channels=100
y_size=fits[0].header['NAXIS2']

# fits[0].header['CRVAL3'] = freq_hz
# fits[0].header['FREQCENT'] = freq_hz

# freq_hz=
# freq_hz = fits[0].header['CRVAL3']

# centchan= (freq_hz/1280000)
# fits[0].header['CENTCHAN'] = int(centchan)
# fits[0].header['CHANNELS'] = int(centchan)
# fits[0].header['CONTINUE'] = ""

fits[0].header['NAXIS'] = 2

fits[0].header.remove('CUNIT3')
fits[0].header.remove('CDELT3')
fits[0].header.remove('CRVAL3')
fits[0].header.remove('CRPIX3')
fits[0].header.remove('CTYPE3')
# fits[0].header.remove('NAXIS3')

fits[0].header.remove('CUNIT4')
fits[0].header.remove('CDELT4')
fits[0].header.remove('CRVAL4')
fits[0].header.remove('CRPIX4')
fits[0].header.remove('CTYPE4')
# fits[0].header.remove('NAXIS4')

# fits[0].header['NAXIS'] = 2
# fits[0].header.remove('NAXIS3')
# fits[0].header.remove('NAXIS4')


# fits[0].header['FREQCENT'] = freq_hz

# data2=fits[0][0].copy()
# fits[0].data=data2


# fits[0].header.clear()

# out_fitsname="test.fits"
out_fitsname=fitsname
print("Writing freq = %d Hz to fits header %s" % (freq_hz,out_fitsname))
fits.writeto( out_fitsname, overwrite=True ) 


