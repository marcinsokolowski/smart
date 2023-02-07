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

def fix_metafits( listfile , obsid, n_scans=1, n_chans=768, inttime=1, flag_file=None ) :
   site="MWA"
   # 2021-09-29 icrs -> fk5
   # frame='icrs'
   frame='fk5'

   metafits_base = ("%d.metafits" % options.obsid)
   if not os.path.exists( metafits_base ) :
      print("ERROR : metafits file %s does not exist" % (metafits_base))
      sys.exit(-1)


   timestamps = read_text_file( listfile )

   for timestamp in timestamps :
      fitsname = ( "%s.metafits" % timestamp )
      
      if not os.path.exists( fitsname ) :
         cmd_cp = ("cp %s %s" % (metafits_base,fitsname))
         print("INFO : metafits file %s not found -> execting |%s|" % (fitsname,cmd_cp))
         os.system( cmd_cp )
      
      print("Updating keyword in metafits %s"  % (fitsname))
      
      # WARNING : time.mktime converts LOCALTIME to UXTIME !!! NOT UTC TIME
      uxtime0 = time.mktime(datetime.strptime( timestamp , "%Y%m%d%H%M%S").timetuple()) # + 8*3600 # +8 hours for Perth
      uxtime = uxtime0 + 8*3600
      t = Time( uxtime  ,format="unix" )
      t_gps = t.replicate(format='gps')
      gps = t_gps.value
      print("DEBUG : %s UTC -> ux0 = %d -> ux = %d" % (timestamp,uxtime0,uxtime))
      
      t_utc = t.replicate( format='datetime' )
      utc_string = t_utc.value.strftime("%Y-%m-%dT%H:%M:%S")

      # azh2radec      
      fits = pyfits.open(fitsname)
      azim     = float( fits[0].header['AZIMUTH'] )
      alt      = float( fits[0].header['ALTITUDE'] )
      print("DEBUG : (azim,alt,uxtime) = (%.8f,%.8f,%.8f)" % (azim,alt,uxtime))
      ( ra_deg, dec_deg ) = azh2radec.azh2radec( uxtime, azim, alt, site=site, frame=frame )
            
      fix_metafits_time_radec.fix_metafits_base( fits , fitsname, dateobs=utc_string, gps=gps, ra=ra_deg, dec=dec_deg, n_chans=n_chans, n_scans=n_scans, inttime=inttime, flag_file=flag_file )

                                            
def parse_options(idx):
   parser=optparse.OptionParser()
   parser.set_usage("""fix_metafits_time_radec_all.py""")
   parser.add_option("--n_channels","--n_chan","--n_ch","-n",dest="n_channels",default=768,help="Number of channels [default: %default]",type="int")
   parser.add_option('-t','--n_scans','--n_timesteps',dest="n_timesteps",default=1, help="Number of timesteps [default %default]", type="int")
   parser.add_option('--flag_file','--flag_tiles_file',dest="flag_file",default=None, help="Flag file with flagged antennas (column Antenna in metafits file = 2nd column [default %default]")
   parser.add_option('-i','--inttime','--inttime_sec',dest="inttime",default=1, help="Integration time in seconds [default %default]", type="int")
   parser.add_option("--obsid","--OBSID","--obs","-o",dest="obsid",default=-1,help="OBSID [default: %default]",type="int")
   (options,args)=parser.parse_args(sys.argv[idx:])
   
   return (options, args)


if __name__ == '__main__':
   # 
   listfile="list.txt"
   if len(sys.argv) > 1:
      listfile = sys.argv[1]

   (options, args) = parse_options(1)
   
   if options.obsid <= 0 :
      print("ERROR : obsid not specified -> cannot continue. Specify OBSID with options --obsid or -o")
      sys.exit(-1)
   
   print("####################################################")
   print("listfile       = %s"   % (listfile))   
   print("inttime        = %d"   % (options.inttime))
   print("Flag file      = %s" % (options.flag_file))
   print("n_channels     = %d" % (options.n_channels))
   print("####################################################")   

   fix_metafits( listfile, obsid=options.obsid, n_scans=options.n_timesteps, n_chans=options.n_channels, inttime=options.inttime, flag_file=options.flag_file )
   