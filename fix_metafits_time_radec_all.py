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
import fix_metafits_time_radec

from datetime import datetime
import time
from astropy.time import Time

import azh2radec

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


def read_text_file( filename ) :
   timestamps=[]

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
         
         t=words[0+0]
         timestamps.append( t )
         if debug > 0 :
            print("DEBUG : added %s" % (t))
      file.close()

   else :
      print("WARNING : empty or non-existing file %s" % (filename))


   return (timestamps)

                                            
def parse_options(idx):
   parser=optparse.OptionParser()
   parser.set_usage("""fix_metafits_time_radec_all.py""")
   parser.add_option("--n_channels","--n_chan","--n_ch","-n",dest="n_channels",default=768,help="Number of channels [default: %default]",type="int")
   parser.add_option("--obsid","--OBSID","--obs","-o",dest="obsid",default=-1,help="OBSID [default: %default]",type="int")
   (options,args)=parser.parse_args(sys.argv[idx:])
   
   return (options, args)


if __name__ == '__main__':
   # 
   listfile="list.txt"
   if len(sys.argv) > 1:
      listfile = sys.argv[1]

#   dateobs=sys.argv[2]
#   gps=sys.argv[3]
#   ra=sys.argv[4]
#   dec=sys.argv[5]
   
   (options, args) = parse_options(1)
   
   if options.obsid <= 0 :
      print("ERROR : obsid not specified -> cannot continue. Specify OBSID with options --obsid or -o")
      sys.exit(-1)
   
   metafits_base = ("%d.metafits" % options.obsid)
   if not os.path.exists( metafits_base ) :
      print("ERROR : metafits file %s does not exist" % (metafits_base))
      sys.exit(-1)
   
   n_scans=1
   n_chans=options.n_channels
   inttime=1
   site="MWA"
   frame='icrs'

   print("####################################################")
   print("listfile       = %s"   % (listfile))
   print("inttime        = %d"   % (inttime))
#   print("n_channels     = %d" % (options.n_channels))
   print("####################################################")
   
   timestamps = read_text_file( listfile )

#  def fix_metafits( fitsname , dateobs, gps, ra, dec, n_chans=768, n_scans=1, inttime=4 ) :
   
   for timestamp in timestamps :
      fitsname = ( "%s.metafits" % timestamp )
      
      if not os.path.exists( fitsname ) :
         cmd_cp = ("cp %s %s" % (metafits_base,fitsname))
         print("INFO : metafits file %s not found -> execting |%s|" % (fitsname,cmd_cp))
         os.system( cmd_cp )
      
      print("Updating keyword in metafits %s"  % (fitsname))
      
      uxtime = time.mktime(datetime.strptime( timestamp , "%Y%m%d%H%M%S").timetuple()) + 8*3600 # +8 hours for Perth
      t = Time( uxtime  ,format="unix" )
      t_gps = t.replicate(format='gps')
      gps = t_gps.value
      
      t_utc = t.replicate( format='datetime' )
      utc_string = t_utc.value.strftime("%Y-%m-%dT%H:%M:%S")

      # azh2radec      
      fits = pyfits.open(fitsname)
      azim     = float( fits[0].header['AZIMUTH'] )
      alt      = float( fits[0].header['ALTITUDE'] )
      ( ra_deg, dec_deg ) = azh2radec.azh2radec( uxtime, azim, alt, site=site, frame=frame )
            
      fix_metafits_time_radec.fix_metafits_base( fits , fitsname, dateobs=utc_string, gps=gps, ra=ra_deg, dec=dec_deg, n_chans=n_chans, n_scans=n_scans, inttime=inttime )



