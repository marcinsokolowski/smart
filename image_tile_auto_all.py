# Script originally created by Natasha Hurley-Walker , then modfied by Tim Colegate 
# finally changed by Marcin Sokolowski
# 
# INPUT  : casa measurements set 
# OUTPUT : image in both instrumental polarisations (XX,YY)
# 
# postfix _auto - refers to trying to automatically adjust optimal imaging parameters based on input parameters 
# 
from time import gmtime, strftime
import optparse
import math

def max_baseline_func(vis) :
   tb.open(vis + '/ANTENNA')
   ant_positions=tb.getcol('POSITION')
   
   max_baseline = -1
   for i in range(0,ant_positions.shape[1]):
      x1 = ant_positions[0,i]
      y1 = ant_positions[1,i]
      z1 = ant_positions[2,i]
      
      for j in range(0,ant_positions.shape[1]):         
         if i != j :
            x2 = ant_positions[0,j]
            y2 = ant_positions[1,j]
            z2 = ant_positions[2,j]
            
            d = math.sqrt( (x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2 )
            if d > max_baseline :
               max_baseline = d 

   tb.close()
   print "max_baseline = %.2f" % (max_baseline)
   return max_baseline               


# create command line arguments
parser=optparse.OptionParser()
parser.set_usage("Usage: casapy [--nologger] -c image_tile_auto.py [options] <filename>.ms")
# parse command line arguments
parser.add_option('-i','--imagesize',dest="imagesize",default=-1, help="Externally passed image size (by default it is calculated automatically for primary beam 25 deg)",metavar="INTEGER",type="int")
parser.add_option('-c','--cellside',dest="cellside",default=-1, help="Externally passed pixel size in arcmin (by default it is calculated automatically)",type="float")
parser.add_option("-u","--uniform",dest="uniform",default=False,action="store_true", help="Uniform weighting (robust=-2) [default: %default]")
parser.add_option("--pols",dest="pols",default='XX,YY', help="Polarisations (opts: XX,XY,YX,YY). [default: %default]")
parser.add_option('-m','--max_baseline',dest="max_baseline",default=3000, help="Longest baseline (should be calculated automatically from measurement set metadata, at the moment 3000m for compact and 5000m for extended configuration) [default %default]",metavar="FLOAT",type="float")

casa_index=sys.argv.index('-c')+2  # remove CASA options
(options,args)=parser.parse_args(sys.argv[casa_index:])
vis=args[-1]  # path to calibrated CASA measurement set

#uvdist in m
uvranges=[]
uvdist_low=[1,85,35,1]
uvdist_high=[1e4,240,1e4,500]
for i in range(0,len(uvdist_low)):
    uvranges.append('%s~%s'%(uvdist_low[i],uvdist_high[i]))
uvranges=[''] #ovveride previous by including all

print "#####################################################################################################################################"
print "PARAMETERS:"
print "#####################################################################################################################################"
print "imagesize = %d" % options.imagesize
print "cellside  = %d" % options.cellside
print "uniform   = %s" % options.uniform
print "#####################################################################################################################################"

# based on rules of thumb:
# resolution ~ lambda/max_baseline ~ 2/1000 * (180/pi)*60 ~ 6.87arcmin
# Rule of thumb http://www.alma.inaf.it/images/114_casaimagingSalome.pdf page 10:
# cellside between 1/5 and 1/3 of the synthesized beam (~lambda/baseline)
# -> cellsize between 1.4 and 2.3 -> ~2arcmin
# TODO : calculate automatically !!!

# imsize=2000#4000 widefield #500 quick
# cellside='0.75arcmin'
imsize=750
cellside='2arcmin'

ms.open(vis)
rec = ms.getdata(['axis_info']) 
df,f0 = (rec['axis_info']['freq_axis']['resolution'][len(rec['axis_info']['freq_axis']['resolution'])/2],rec['axis_info']['freq_axis']['chan_freq'][len(rec['axis_info']['freq_axis']['resolution'])/2]) 
ms.close()
lambda_m=300000000/f0
# max_baseline=options.max_baseline # TODO : should be calculated based on uvdist_high ~5000 for long baselines and 300 for compact configuration
max_baseline = max_baseline_func(vis)

synthesized_beam=(lambda_m/max_baseline)*(180.00/math.pi)*60.00 # in arcmin
lower=synthesized_beam/5.00
higher=synthesized_beam/3.00
primary_beam_deg=25 # 25deg @ 150 MHz, 20deg @ 200 MHz 
cellside_float=(lower+higher)*0.5
if options.cellside > 0 : # overwrite with external paramter if specified 
   print "INFO : overwriting cellside=%.2f with externally provided parameter = %d" % (cellside_float,options.cellside)
   cellside_float = options.cellside

cellside=('%.2f' % cellside_float) + 'arcmin'
n_prim_beams=1 # but somewhere it says that it should be 2 primary beams imaged (http://www.alma.inaf.it/images/114_casaimagingSalome.pdf) 
               # At least twice the primary beam size or more and avoid bright sources near the edge of the image that would cause aliasing
               # testing both 
imsize=int((primary_beam_deg*n_prim_beams*60)/cellside_float)
if (imsize % 100) != 0 :
   rest=100 - (imsize % 100)
   imsize = imsize + rest

if imsize==1700 :
   imsize = 1800

if options.imagesize > 0 : # overwrite with external paramter if specified
   print "INFO : overwriting imsize=%d with externally provided parameter = %d" % (imsize,options.imagesize)
   
   imsize_deg = (options.imagesize*cellside_float) / 60.00
   print "INFO : externally provided imsize -> Image size = %.2f x %.2f [deg^2]" % (imsize_deg,imsize_deg)
   
   if imsize_deg > 1.5*primary_beam_deg :
       print "WARNING : > 1.5*primary_beam = %.2f [deg] -> externally provided imsize %d ignored !" % ((1.5*primary_beam_deg),int(options.imagesize))
   else :
       imsize = options.imagesize


print "Primary beam = %.2f [deg]" % primary_beam_deg
print "Image size   = %d x %.2f [deg]" % (n_prim_beams,primary_beam_deg)
print "Calculated synthesized beam = %.2f [arcmin]" % synthesized_beam
print "Derived cellside = %.2f = (%.2f/5 + %.2f/3)/2" % (cellside_float,synthesized_beam,synthesized_beam)
print "Images size = %d x %d px" % (imsize,imsize)


#imsize=1400*5#1440 for 5 arcmin image
#cellside='1arcmin' #'0.75arcmin'
#weights=['briggs','natural','uniform']
weights=['briggs']
robusts=[-1]
stokeses=options.pols.split(',') # was stokeses=['XX', 'YY']
#stokeses=['YY']
#antennas=['Tile079', 'Tile076','']
antennas=['']
cyclefactor=30#10 #Was 1.5
threshold='300mJy' #Was 30mJy
psfmodes=['clark'] #Was also hogbom 
niter=10000 # was 40000 then 15000 is OK too (RW : overkill !), 10000 gives the same results as 15000 (see MWA/loogbook/201609/mwa_extension_test1.odt )

if options.uniform :
   robusts=[-2]

weight='briggs'
for weight in weights:
    print 'Imaging %s'%(vis)
    name_base=vis 
    for antenna in antennas:
        for stokes in stokeses:
            for robust in robusts:
                for psfmode in psfmodes:
                    for uvrange in uvranges:
                        if antenna!='':
                            cyclefactor=cyclefactor
                        else:
                            cyclefactor=10#1.5 #For full MWA have lower cyclefactor
#                            threshold='30mJy'
                        print 'Cleaning %s stokes %s with weight %s (robust=%s), threshold %s,  cyclefactor %s, psfmode %s' % (antenna, stokes, weight, robust, threshold, cyclefactor, psfmode)
                        print 'Time now is %s' % strftime("%Y-%m-%d %H:%M:%S")

                         
                         
                        timerange_ranges = [ "2016/06/17/21:35:44","2016/06/17/21:35:48","2016/06/17/21:35:52","2016/06/17/21:35:56","2016/06/17/21:36:00","2016/06/17/21:36:04","2016/06/17/21:36:08","2016/06/17/21:36:12","2016/06/17/21:36:16","2016/06/17/21:36:20","2016/06/17/21:36:24","2016/06/17/21:36:28","2016/06/17/21:36:32","2016/06/17/21:36:36","2016/06/17/21:36:40","2016/06/17/21:36:44","2016/06/17/21:36:48","2016/06/17/21:36:52","2016/06/17/21:36:56","2016/06/17/21:37:00","2016/06/17/21:37:04","2016/06/17/21:37:08","2016/06/17/21:37:12","2016/06/17/21:37:16","2016/06/17/21:37:20","2016/06/17/21:37:24","2016/06/17/21:37:28","2016/06/17/21:37:32","2016/06/17/21:37:36","2016/06/17/21:37:40","2016/06/17/21:37:44","2016/06/17/21:37:48","2016/06/17/21:37:52","2016/06/17/21:37:56","2016/06/17/21:38:00","2016/06/17/21:38:04","2016/06/17/21:38:08","2016/06/17/21:38:12","2016/06/17/21:38:16","2016/06/17/21:38:20","2016/06/17/21:38:24","2016/06/17/21:38:28","2016/06/17/21:38:32","2016/06/17/21:38:36","2016/06/17/21:38:40","2016/06/17/21:38:44","2016/06/17/21:38:48","2016/06/17/21:38:52","2016/06/17/21:38:56","2016/06/17/21:39:00","2016/06/17/21:39:04","2016/06/17/21:39:08","2016/06/17/21:39:12","2016/06/17/21:39:16","2016/06/17/21:39:20","2016/06/17/21:39:24","2016/06/17/21:39:28","2016/06/17/21:39:32","2016/06/17/21:39:36","2016/06/17/21:39:40","2016/06/17/21:39:44","2016/06/17/21:39:48","2016/06/17/21:39:52","2016/06/17/21:39:56","2016/06/17/21:40:00","2016/06/17/21:40:04","2016/06/17/21:40:08","2016/06/17/21:40:12","2016/06/17/21:40:16","2016/06/17/21:40:20","2016/06/17/21:40:24","2016/06/17/21:40:28","2016/06/17/21:40:32","2016/06/17/21:40:36","2016/06/17/21:40:40","2016/06/17/21:40:44","2016/06/17/21:40:48","2016/06/17/21:40:52","2016/06/17/21:40:56","2016/06/17/21:41:00","2016/06/17/21:41:04","2016/06/17/21:41:08","2016/06/17/21:41:12","2016/06/17/21:41:16","2016/06/17/21:41:20","2016/06/17/21:41:24","2016/06/17/21:41:28","2016/06/17/21:41:32","2016/06/17/21:41:36","2016/06/17/21:41:40","2016/06/17/21:41:44","2016/06/17/21:41:48","2016/06/17/21:41:52","2016/06/17/21:41:56","2016/06/17/21:42:00","2016/06/17/21:42:04","2016/06/17/21:42:08","2016/06/17/21:42:12","2016/06/17/21:42:16","2016/06/17/21:42:20"]

                        for timeindex in range(0,len(timerange_ranges)-1) : 
                           timerange_string = timerange_ranges[timeindex] + "~" + timerange_ranges[timeindex+1]
                           
                           
                           timeindex_str = ('%04d' % timeindex)
                           imagename=name_base+'_'+weight+str(robust)+'_TH'+threshold+'_CF'+str(cyclefactor)\
                                  +'_'+psfmode+'_'+antenna+'_'+stokes+'_'+cellside+'_'+str(imsize)+'px'+'_UV'+uvrange + '_niter' + str(niter) + '_timeindex' + timeindex_str
                           print 'Imagename: %s ( time range = %s)' % (imagename,timerange_string)
                           
                            
                           clean (vis=vis, imagename=imagename, gridmode ='widefield', psfmode=psfmode,
                               robust=robust, weighting=weight, imagermode ='csclean', wprojplanes =1, 
                               facets =1, niter = niter, imsize =[imsize,imsize], cell =[cellside,cellside], 
                               threshold=threshold, stokes=stokes, mode ='mfs', selectdata =True, 
                               uvrange=uvrange, antenna=antenna, cyclefactor=cyclefactor,usescratch=False,
                               timerange=timerange_string)

                           exportfits(imagename+'.image', imagename+'.fits',overwrite=True)

print 'Imaging completed at %s' % strftime("%Y-%m-%d %H:%M:%S")
