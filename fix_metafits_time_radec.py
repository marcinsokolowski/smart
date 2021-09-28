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
from optparse import OptionParser,OptionGroup


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

# parser.add_option('-c','--n_channels','--n_chans',dest="n_channels",default=768, help="Number of channels [default %default]", type="int")
# parser.add_option('-t','--n_scans','--n_timesteps',dest="n_timesteps",default=1, help="Number of timesteps [default %default]", type="int")
# parser.add_option('-i','--inttime','--inttime_sec',dest="inttime",default=4, help="Integration time in seconds [default %default]", type="int")

                                            
def parse_options(idx):
   parser=optparse.OptionParser()
   parser.set_usage("""fix_metafits_time_radec.py""")
   parser.add_option("--n_channels","--n_chan","--n_ch","-n",dest="n_channels",default=768,help="Number of channels [default: %default]",type="int")
   parser.add_option('-t','--n_scans','--n_timesteps',dest="n_timesteps",default=1, help="Number of timesteps [default %default]", type="int")
   parser.add_option('--flag_file','--flag_tiles_file',dest="flag_file",default=None, help="Flag file with flagged antennas (column Antenna in metafits file = 2nd column [default %default]")
   (options,args)=parser.parse_args(sys.argv[idx:])
   
   return (options, args)

def read_flagged_antennas( filename ) :
   antlist=[]

   cnt = 0
   if os.path.exists(filename) and os.stat(filename).st_size > 0 :
      file=open(filename,'r')
      data=file.readlines()
      for line_tmp in data :
         line = line_tmp.strip("\n")
         if debug > 0 :
            print("DEBUG1 : line = |%s|" % (line))
         words = line.split(' \n')
         if line[0] == '#' :
            continue

         t=int(words[0+0])
         antlist.append( t )
         if debug > 0 :
            print("DEBUG : added %d" % (t))
      file.close()

   else :
      print("WARNING : empty or non-existing file %s" % (filename))


   return (antlist)



def fix_metafits( fitsname , dateobs, gps, ra, dec, n_chans=768, n_scans=1, inttime=4 , flag_file=None ) :
   fits = pyfits.open(fitsname)
      
   fix_metafits_base( fits , fitsname, dateobs, gps, ra, dec, n_chans=n_chans, n_scans=n_scans, inttime=inttime ) 
   

def fix_metafits_base( fits , fitsname, dateobs, gps, ra, dec, n_chans=768, n_scans=1, inttime=1, flag_file=None ) :
   # fits = pyfits.open(fitsname)

   fits[0].header['DATE-OBS']  = dateobs
   fits[0].header['GPSTIME']   = int(gps)
   fits[0].header['RA']        = float(ra)
   fits[0].header['DEC']       = float(dec)
   fits[0].header['NSCANS']    = n_scans
   fits[0].header['INTTIME']   = inttime
   fits[0].header['NCHANS']    = n_chans

   if flag_file is not None : 
     print("Flag file %s specified -> reading" % (flag_file))
     flagged_antenna_list = read_flagged_antennas( flag_file )
     print("Read %d flagged antennas from file %s" % (len(flagged_antenna_list),flag_file))
   
     # see function list_tile_name in metadata_auto.py :
     for i in range(0,256):
        idx=table[i][0]
        tile_idx=table[i][1]
        tile_id=table[i][2]
        tile_name=table[i][3]
        tile_pol=table[i][4]
        delays=table[i][12]
        flag=table[i][7]
        
        if tile_idx in flagged_antenna_list :
           if flag == 0 :
              print("Flagging tile %s (tile_idx = %d, tile_id = %d)" % (tile_name,tile_idx,tile_id))
              table[i][7] = 1


   print("Writing fits %s" % (fitsname))
   fits.writeto( fitsname, overwrite=True ) 


if __name__ == '__main__':
   # 
   if len(sys.argv) > 1:
      fitsname = sys.argv[1]

   dateobs=sys.argv[2]
   gps=sys.argv[3]
   ra=sys.argv[4]
   dec=sys.argv[5]
   
   (options, args) = parse_options(6)
   
   n_scans = options.n_timesteps
   n_chans=options.n_channels
   inttime=1

   print("####################################################")
   print("fitsname       = %s"   % fitsname)
   print("n_channels     = %d" % (options.n_channels))
   print("inttime        = %d" % (inttime))
   print("Flag file      = %s" % (options.flag_file))
   print("####################################################")

   fix_metafits( fitsname, dateobs, gps, ra, dec, n_chans=n_chans, n_scans=n_scans, inttime=inttime , flag_file=options.flag_file )

