#!/opt/caastro/ext/anaconda/bin/python

# import pdb
import astropy.io.fits as pyfits
# import pylab
import math
from array import *
# from pylab import *
# import matplotlib.pyplot as plt
# import numpy as np
import string
import sys
import os,re
import errno
import getopt
from optparse import OptionParser,OptionGroup

# global parameters :
debug=0
fitsname="1078140304.metafits"
do_show_plots=0
do_gif=0

center_x=1025
center_y=1025
radius=600

C_ms  = 299798000.00 # m/s
C_MHz = 299.79800000 # 

def mkdir_p(path):
   try:
      os.makedirs(path)
   except OSError as exc: # Python >2.5
      if exc.errno == errno.EEXIST:
         pass
      else: raise
                                            
def parse_options():
   usage="Usage: %prog [options]\n"
   usage+='\tList antennas\n'
   parser = OptionParser(usage=usage,version=1.00)
   parser.add_option('--max_baseline',dest="max_baseline",action="store_true", default=False, help="Calculate maximum baseline [default %default]")
#   parser.add_option('-p','--pol',dest="selected_pol",default="X", help="Selected polarisation",metavar="STRING")
#   parser.add_option('-f','--freq',dest="freq",default=230, help="Frequency in MHz",metavar="FLOAT",type="float")
#   parser.add_option('--tilenames2zeroidx',dest="tilename2zeroidx",default=None, help="Convert list tile names to 0-indexed list [default %default]")
   parser.add_option('--outfile','--out_file',dest="outfile",default=None, help="Output file [default %default]")
#   parser.add_option('-b','--bad','--flagged',action="store_true",dest="list_flagged",default=False, help="List flagged only")
   parser.add_option('--all','--save_all',dest="save_all",action="store_true", default=False, help="Save all [default %default]")
   parser.add_option('--dump_ant_positions','--save_ant_positions',dest="save_ant_positions",action="store_true", default=False, help="Save antenna positions [default %default]")
   (options, args) = parser.parse_args()
                                
   return (options, args)



def find_tile_idx( table, tile_name_param, pol ) :
   for i in range(0,256):
     idx=table[i][0]
     tile_idx=table[i][1]
     tile_id=table[i][2]
     tile_name=table[i][3]
     tile_pol=table[i][4]
     delays=table[i][12]
     tile_out_name="T%03d%s" % (tile_idx,tile_pol)
  
     # print "DEBUG : %s %s %d" % (tile_name,tile_pol,tile_idx)

     if tile_name == tile_name_param and tile_pol == pol :
        return tile_idx

   return -1

def get_tile_id( table, tile_name_param, pol ) :
   for i in range(0,256):
     idx=table[i][0]
     tile_idx=table[i][1]
     tile_id=table[i][2]
     tile_name=table[i][3]
     tile_pol=table[i][4]
     delays=table[i][12]
     flag=table[i][7]
     tile_out_name="T%03d%s" % (tile_idx,tile_pol)
  
     # print "DEBUG : %s %s %d" % (tile_name,tile_pol,tile_idx)

     if tile_name == tile_name_param and tile_pol == pol :
        return tile_id

   return -1

def tilename2zeroidx( in_file, table, out_file ) :
   tile_list = loadtxt(in_file,dtype="string")
   
   f = open(out_file, 'w')
   for i in range(0,tile_list.shape[0]):
      tile_name=tile_list[i]
      
      # X pol :
      tile_idx_x=find_tile_idx(table,tile_name,pol="X")
      outline = str(tile_idx_x) + ","
      f.write(outline)
      
      # Y pol :
      # tile_idx_y=find_tile_idx(table,tile_name,pol="Y")      
      # outline = str(tile_idx_y) + ","
      # f.write(outline)

      
   f.write("\n")
   f.close()   

def list_tile_name( table, out_file, flagged_only=False ) :
   f = open(out_file, 'w')

   tiles_out={}
   for i in range(0,256):
     idx=table[i][0]
     tile_idx=table[i][1]
     tile_id=table[i][2]
     tile_name=table[i][3]
     tile_pol=table[i][4]
     delays=table[i][12]
     flag=table[i][7]
     
     tile_out_name="T%03d%s" % (tile_idx,tile_pol)
  
     # print "DEBUG : %s %s %d" % (tile_name,tile_pol,tile_idx)

     if tile_pol == "X" :
        # print "flagged_only = %s , flag = %d" % (flagged_only,flag)
        if not flagged_only or flag > 0  :
           outline = str(tile_name) + " " + str(tile_id) + " " + str(flag) + " " + str(tile_idx) + "\n"                      
           f.write(outline)
           
           tiles_out[tile_idx] = tile_name
        #else :
        #   print "Skipped tile %s" % tile_name
  

   f.close()

   return tiles_out

def calc_max_baseline(table,n_ant=256) :
   max_baseline = -1
   for i in range(0,n_ant):
      n1 = table[i][9]
      e1 = table[i][10]
      h1 = table[i][11]

      for j in range((i+1),n_ant):
         n2 = table[j][9]
         e2 = table[j][10]
         h2 = table[j][11]

         d = math.sqrt( (n1-n2)**2 + (e1-e2)**2 + (h1-h2)**2 )
         if d > max_baseline :
            max_baseline = d 

   print("max_baseline = %.2f" % (max_baseline))
   return max_baseline

def save_ant_positions( table , out_f , n_input=256 ) :
   # saving in sorted order :
   for i in range(0,n_input):
      idx=table[i][0]
      tile_idx=table[i][1] # Antenna Index in CASA 
      tile_id=table[i][2]
      tile_name=table[i][3]
      tile_pol=table[i][4]
      delays=table[i][12]
      flag=table[i][7]
      el_length=table[i][8]
      north_m=table[i][9]
      east_m=table[i][10]
      height_m=table[i][11]

      if tile_pol == "X" :
         line = ("%d %s %.8f %.8f %.8f\n" % (tile_idx,tile_name,north_m,east_m,height_m))
         out_f.write( line )
      
  
   

def count_baselines( table, obs_freq_mhz=154.88, min_uv_l=-10000, max_uv_l=1e20 ):
   n_ant = len(table)
   print("Number of antennas = %d" % (n_ant))

   baseline_count = 0
   all_baseline_count = 0
   max_baseline = -1
   wavelength = C_MHz / obs_freq_mhz
   
   print("Wavelength = %.4f [m]" % (wavelength))
   
   for i in range(0,n_ant):
      n1 = table[i][9]
      e1 = table[i][10]
      h1 = table[i][11]

      for j in range((i+1),n_ant):
         n2 = table[j][9]
         e2 = table[j][10]
         h2 = table[j][11]

         d = math.sqrt( (n1-n2)**2 + (e1-e2)**2 + (h1-h2)**2 )
         d_l = d / wavelength         
         
         # count all baselines :
         all_baseline_count += 1

         # find maximum baseline
         if d > max_baseline :
            max_baseline = d 
            
         # count baselines within the requested UV range :
         if d_l >= min_uv_l and d_l <= max_uv_l :
            baseline_count += 1    


   n_b = ((n_ant-1)*n_ant)/2
   print("max_baseline = %.2f" % (max_baseline))
   print("Number of baselines in uv_range %.4f - %.4f is %d out of all %d (%d)" % (min_uv_l,max_uv_l,baseline_count,all_baseline_count,n_b))
   
   return (baseline_count,all_baseline_count,max_baseline)

def main() :
   if len(sys.argv) > 1:
      fitsname = sys.argv[1]
   obsid=re.sub('.metafits','',fitsname)   
   
   outfile = fitsname.replace(".metafits",".metadata_info")

   (options, args) = parse_options()
   
   if options.outfile is not None :
      outfile = options.outfile
   
   print("####################################################")
   print("PARAMTERS :")
   print("####################################################")
   print("fitsname       = %s -> obsID = %s" % (fitsname,obsid))
   print("Max baseline   = %s" % (options.max_baseline))
   print("outfile        = %s" % (outfile))
   print("Save antenna positions = %s" % (options.save_ant_positions))
   print("####################################################")

   fits = pyfits.open(fitsname)
   table = fits[1].data
   print("Read fits file %s" % fitsname)

   out_f = open( outfile, "w")

   if options.save_ant_positions :
      save_ant_positions( table , out_f )
      sys.exit(-1)
   
   max_baseline = -100 
   if options.max_baseline or options.save_all :
      max_baseline = calc_max_baseline( table )
      print("Maximum baseline = %.4f [m]" % (max_baseline))
      out_f.write("MAX_BASELINE = %.4f\n" % (max_baseline))
      
      freqcent = fits[0].header['FREQCENT']
      freqcent_hz = freqcent*1e6
      out_f.write("FREQCENT = %.2f MHz = %.2f Hz\n" % (freqcent,freqcent_hz))
      
      lambda_m = 300000000/freqcent_hz
      out_f.write("LAMBDA = %.4f [m]\n" % lambda_m);
      
      # based on rules of thumb:
      # resolution ~ lambda/max_baseline ~ 2/1000 * (180/pi)*60 ~ 6.87arcmin
      # Rule of thumb http://www.alma.inaf.it/images/114_casaimagingSalome.pdf page 10:
      # cellside between 1/5 and 1/3 of the synthesized beam (~lambda/baseline)
      # -> cellsize between 1.4 and 2.3 -> ~2arcmin
      # TODO : calculate automatically !!!
      # see also image_tile_auto.py
      synthesized_beam=(lambda_m/max_baseline)*(180.00/math.pi)*60.00 # in arcmin
      lower=synthesized_beam/5.00
      higher=synthesized_beam/3.00
      primary_beam_deg=25 # 25deg @ 150 MHz, 20deg @ 200 MHz 
      out_f.write("SYNTH_BEAM = %.4f [arcmin]\n" % synthesized_beam)
      cellside_float=(lower+higher)*0.5
      out_f.write("PIXSCALE = %.1f [arcmin] = %.4f [deg]\n" % (cellside_float,cellside_float/60.00))


   if options.save_all :
      n_scans = fits[0].header['NSCANS']
      out_f.write("N_SCANS = %d\n" % n_scans)
      
   if options.save_all :
      inttime = fits[0].header['INTTIME']
      out_f.write("INTTIME = %.2f\n" % inttime)

   
   fits.close()
   out_f.close()

#   if options.tilename2zeroidx is not None :
#      tilename2zeroidx( options.tilename2zeroidx, table, out_file )
#   else :       
#      list_tile_name( table, out_file, flagged_only=options.list_flagged )

if __name__ == "__main__":
   main()
