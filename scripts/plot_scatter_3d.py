import numpy as np
import astropy.wcs as wcs
import astropy.io.fits as pf
from astropy import units as au
from astropy.coordinates import SkyCoord
from astropy.coordinates import Angle
from astropy.table import Table
import ephem
import os
import glob
import datetime
import pytz
import sys
import scipy.linalg
from mpl_toolkits.mplot3d import Axes3D
import math
import copy
from optparse import OptionParser,OptionGroup

import re

import matplotlib as m
import matplotlib.pyplot as plt
plt.style.use('seaborn-whitegrid')
import numpy as np

try:
    import astropy.io.fits as pyfits
    import astropy.wcs as pywcs
    _useastropy=True
except ImportError:
    import pywcs,pyfits
    _useastropy=False


# Constants
C = 2.99792458e8
r2h = 12.0/np.pi
r2d = 180.0/np.pi
h2d = 360.0/24.0
d2h = 24.0/360.0
ARCMIN2RAD = np.pi / (60.0 * 180.0)
DEG2RAD = ( math.pi / 180.00)
RAD2DEG = ( 180.00 / math.pi )
RAD2ARCSEC = ( ( 180.00 / math.pi )*3600. )



#  X   Y   RA_image[deg]    DEC_image[deg]  Flux_image[Jy]   RA_gleam[deg]    DEC_gleam[deg]    Flux_gleam[Jy]   AngDist[arcsec]    CalConst
# 16   2930   284.3990    -23.1885    0.023    284.3999    -23.1880    0.569    3.40    24.60445805 
def read_text_file( filename ) :
   x_list = []
   y_list = []
   calconst_list = []

   if os.path.exists(filename) and os.stat(filename).st_size > 0 :
      file=open(filename,'r')
      data=file.readlines()
      for line in data :
         if line[0] != "#" :
#            words = line.split(' ')
            words = re.split( '\s+' , line )
         
            print("DEBUG : line = %s -> |%s|%s|" % (line,words[0+0],words[1+0]))
            x = float(words[0+0])
            y = float(words[1+0])
            ra = float(words[2+0])
            dec = float(words[3+0])
            flux_image = float(words[4+0])
            ra_gleam = float(words[5+0])
            dec_gleam = float(words[6+0])
            flux_gleam = float(words[7+0])
            angdist_arcsec = float(words[8+0])
            calconst = float(words[9+0])
         
            if calconst < 1000 :
               x_list.append(x)
               y_list.append(y)
               calconst_list.append(calconst)
            
      file.close()      
   else :
      print "WARNING : empty or non-existing file %s" % (filename)

   print("READ %d values from file %s" % (len(x_list),filename))
   
   return (x_list,y_list,calconst_list)

def plot_scatter( filename ) :   
   (x_list,y_list,calconst_list) = read_text_file( filename )
   # rng = np.random.RandomState(0)
   x = x_list # rng.randn(100)
   y = y_list # rng.randn(100)
   colors = calconst_list
   sizes = 50 # * rng.rand(100)

   # https://stackoverflow.com/questions/3373256/set-colorbar-range-in-matplotlib
   cdict = {
     'red'  :  ( (0.0, 0.25, .25), (0.02, .59, .59), (1., 1., 1.)),
     'green':  ( (0.0, 0.0, 0.0), (0.02, .45, .45), (1., .97, .97)),
     'blue' :  ( (0.0, 1.0, 1.0), (0.02, .75, .75), (1., 0.45, 0.45))
   }

   cm = m.colors.LinearSegmentedColormap('my_colormap', cdict, 1024)
   plt.clf()
#   plt.pcolor(x, y, colors, cmap=cm, vmin=-4, vmax=4)
#   plt.pcolor(x, y, colors, cmap=cm)
#   plt.loglog()
   plt.xlabel('X pixel')
   plt.ylabel('Y pixel')
#   plt.zlabel('Ratio Flux_gleam / Flux_image')


   # https://matplotlib.org/stable/gallery/shapes_and_collections/scatter.html
   # plt.scatter(x, y, c=colors, s=sizes, alpha=0.3, cmap=cm )
   # plt.scatter(x, y, c=colors, s=sizes, alpha=1.0, cmap='rainbow', vmin=0.00, vmax=20 ) # cmap='viridis')
   
   # 3D : https://jakevdp.github.io/PythonDataScienceHandbook/04.12-three-dimensional-plotting.html
   ax = plt.axes(projection='3d')
   ax.scatter3D( x, y, colors, c=colors, cmap='rainbow' );
   
#   plt.colorbar();  # show color scale   
   plt.show()
   

if __name__ == '__main__':
   filename = "mean_stokes_I_2axis_gleamcal.txt"
   if len(sys.argv) > 1:
      filename = sys.argv[1]
      
   
   plot_scatter( filename )   
      
      


