from __future__ import print_function

# import pdb

import datetime
import time
import numpy
import os,sys,errno
import math
from string import Template

# import pyfits
import astropy.io.fits as pyfits
import astropy # for sun 
from astropy.time import Time # for sun

# turn-off downloading ephemeirs files :
from astropy.utils.iers import conf
conf.auto_max_age = None
from astropy.utils import iers
iers.conf.auto_download = False  


# options :
from optparse import OptionParser,OptionGroup

try :
   # from astropy.coordinates import SkyCoord, EarthLocation, get_sun
   from astropy.coordinates import AltAz, EarthLocation, SkyCoord
   # CONSTANTS :
   MWA_POS=EarthLocation.from_geodetic(lon="116:40:14.93",lat="-26:42:11.95",height=377.8)

#   import sky2pix
#   from astropy.time import Time
except :
   print("WARNINF : could not load astropy.coordinates - Sun elevation cuts will not work")   
   MWA_POS=None


def parse_options(idx=0):
   usage="Usage: %prog [options]\n"
   usage+='\tCount spikes above specified threshold, but exclude those coinciding with OFF-OBJECT spikes (most likely RFI or other artefacts, like side-lobes etc)\n'
   parser = OptionParser(usage=usage,version=1.00)
   
#   parser.add_option('--max_delay_sec',dest="max_delay_sec",default=2,help="Maximum dispersion delay to check coincidence for [default %default]",type="float")
   parser.add_option('--coinc_radius_deg',dest="coinc_radius_deg",default=3.3,help="Coincidence radius in degrees [default 1 beam size %default]",type="float")
   parser.add_option('--object_name','--name',dest="object_name",default="B0950+08",help="Object name [default %default]")
   parser.add_option('--object_lc','--object_lightcurve','--lightcurve',dest="object_lightcurve",default="B0950+08_diff.txt",help="On object lightcurve [default %default]")   
   parser.add_option('--off_lc','--off_object_lightcurve','--off_lightcurve','--reference_lightcurve',dest="off_lightcurve",default="OFF_B0950+08_diff.txt",help="Off-object lightcurve [default %default]")
   parser.add_option('--inttime','--integration_time',dest="inttime",default=2,help="Integration time [default %default]",type="float")
   parser.add_option('--freq_ch','--ch','--channel',dest="freq_channel",default=294,help="Frequency channel [default %default]",type="int")
   parser.add_option('--thresh','--threshold',dest="threshold",default=38,help="Integration time [default %default]",type="float")
   parser.add_option('--outdir','--out_dir','--output_dir','--dir',dest="outdir",default="lc_filtered/",help="Output directory [default %default]")
   parser.add_option('--use_diff_candidates','--use_candidates',action="store_true",dest="use_diff_candidates",default=False, help="Use candidates from difference images [default %]")   
   parser.add_option('--max_rmsiqr','--maximum_rmsiqr',dest="maximum_rmsiqr",default=100,help="Maximum allowed value of RMS-IQR [default %default]",type="float")

   parser.add_option('--ra_deg',dest="ra_deg",default=None,help="RA [deg] [default %default]",type="float")
   parser.add_option('--dec_deg',dest="dec_deg",default=None,help="DEC [deg] [default %default]",type="float")
   
   # RFI excision : 
   parser.add_option('--rfi_flux_threshold','--rfi_thresh','--rfi',dest="rfi_flux_threshold",default=1500,help="RFI threshold [default %default]",type="float")
   
   # sun cuts due to very high values in side-lobes :
   parser.add_option('--max_sun_elev','--max_sun_elevation',dest="max_sun_elevation",default=100,help="Maximum Sun elevation allowed [default %default , >= 90 effectively turns this cut off]",type="float")


   (options, args) = parser.parse_args(sys.argv[idx:])

   return (options, args)

# 20210929 : changes to make it compatible with azh2radec (libnova) and azh2ad (PIOTS) see notes in /home/msok/Desktop/PAWSEY/PaCER/logbook/20210928_check_tile_flagging_comparison.odt
# changes :
#    frame='icrs' -> frame='fk5'
#    equinox=current_equinox
# also : https://docs.astropy.org/en/stable/time/index.html
def azh2radec( uxtime, azim, alt, site="MWA", frame='fk5' ) : # was icrs 
   ut_time = Time( uxtime ,format='unix')

   t=ut_time.copy()
   t.format='byear' # https://docs.astropy.org/en/stable/time/index.html
   
   newAltAzcoordiantes = SkyCoord(alt = alt, az = azim, obstime = ut_time, frame = 'altaz', unit='deg', location=MWA_POS, equinox=t )
   altaz = newAltAzcoordiantes.transform_to( frame )
   ra_deg, dec_deg = altaz.ra.deg, altaz.dec.deg
   print("(RA,DEC) = ( %.8f , %.8f )" % (ra_deg,dec_deg))
   
   return ( ra_deg, dec_deg )



if __name__ == "__main__":
#   (options, args) = parse_options()
   uxtime = 0.00
   if len(sys.argv) > 1: 
      uxtime = float( sys.argv[1] )

   site="MWA"
   if len(sys.argv) > 2: 
      site = sys.argv[2]

   azim = 0.00
   if len(sys.argv) > 3: 
      azim = float( sys.argv[3] )

   alt = 0.00
   if len(sys.argv) > 4: 
      alt = float( sys.argv[4] )
      
   frame='icrs' # FK5
   if len(sys.argv) > 5: 
      frame = sys.argv[5]

   
   ( ra_deg, dec_deg ) = azh2radec( uxtime, azim, alt, site=site, frame=frame )
      
##   print( "%.2f %.4f %.4f" % (uxtime,ra,dec) )

#   ut_time = Time( uxtime ,format='unix')

##   coord = SkyCoord( azim, alt, equinox='J2000',frame='altaz', unit='deg')
##   coord = SkyCoord( azim, alt, frame='altaz', unit='deg')

   # https://docs.astropy.org/en/stable/api/astropy.coordinates.AltAz.html   
##   coord = AltAz(alt=alt, az=azim, obstime=Time( uxtime, scale='utc', format="unix" ), location=MWA_POS, unit='deg' )
##   coord.location = MWA_POS
##   coord.obstime = Time( uxtime, scale='utc', format="unix" )
##   altaz = coord.transform_to('icrs')
##   ra_deg, dec_deg = altaz.ra.deg, altaz.dec.deg
   
##   print("(RA,DEC) = ( %.8f , %.8f )" % (ra_deg,dec_deg))


#   newAltAzcoordiantes = SkyCoord(alt = alt, az = azim, obstime = ut_time, frame = 'altaz', unit='deg', location=MWA_POS )
##   newAltAzcoordiantes.coord = MWA_POS
#   altaz = newAltAzcoordiantes.transform_to( frame )
#   ra_deg, dec_deg = altaz.ra.deg, altaz.dec.deg
#   print("(RA,DEC) = ( %.8f , %.8f )" % (ra_deg,dec_deg))
   