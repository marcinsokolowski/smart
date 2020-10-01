# Generate automatic calibration model and form a bandpass solution
# Requires pywcs-1.9-4.4.4 and numpy-1.7.0 or numpy-1.6.2 installed into casapy
# You can do this by installing PAPERcasa, and using 'casapython' to install the modules

# Natasha Hurley-Walker 10/07/2013
# Updated 08/08/2013 to scale the YY and XX beams separately
# Updated 01/10/2013 Use the field name as the calibrator name if the calibrator wasn't filled in properly during scheduling
# Updated 21/11/2013 Added sub-calibrators to complex fields (but didn't find much improvement)
# Updated 02/12/2013 Added a spectral beam option; turned subcalibrators off by default

# Modified by Tim Colegate, 2/04/14 to exclude primary beam correction
# Updated 27/06/14 to get correct frequency from fits file for scaling
import subprocess, re
#import mwapy.get_observation_info
#from mwapy.obssched.base import schedule
import numpy as n,os,sys,shutil
from pylab import *
import optparse

# create command line arguments
parser=optparse.OptionParser()
parser.set_usage("Usage: casapy [--nologger] -c ft_beam_cal_only.py [options] <calibratorname> <model directory> <filename>.ms")
# parse command line arguments
parser.add_option("--exclude_AAVS",dest="exclude_AAVS",default=False,action="store_true",
                          help="If True, exclude AAVS (Tile079) from calibration. [default: %default]")
parser.add_option("--uvdist_low",dest="uvdist_low",default=30,
                          help="Minimum baseline UV distance (wavelengths) to be included. [default: %default]")
parser.add_option("--uvdist_high",dest="uvdist_high",default=1e6, help="Maximum baseline UV distance (wavelengths) to be included. [default: %default]")
parser.add_option("--refant",dest="refant",default="2",help="Reference antenna [default: %default, for compact configuration it was Tile012 and for extended Tile052]")
casa_index=sys.argv.index('-c')+2  # remove CASA options
(options,args)=parser.parse_args(sys.argv[casa_index:])
exclude_AAVS=options.exclude_AAVS
uvdist_low=float(options.uvdist_low)
uvdist_high=float(options.uvdist_high)
#Hack to get calibrator name - NGAS issue
calibrator=args[-3].strip()

vis=args[-1]  # path to calibrated CASA measurement set
#vises=vises.split(',') # convert to list
#print vises

# Attempte to autoset directories
# Model location:
modeldir=args[-2]
modeldir=modeldir.strip()
#modeldir=os.environ['MWA_CODE_BASE']+'/MWA_Tools/Models/'
# Make_beam.py and other scripts:
bindir=os.environ['HOME']+'/bin/'
# Supercomputers:
if not os.path.exists(bindir+'make_beam.py'):
  bindir=os.environ['MWA_CODE_BASE']+'/bin/'

#for vis in vises:
# vis should be defined before you start
caltable=re.sub('ms','cal',vis)
# Reference antenna
#refant='Tile012'
#refant='Tile052' # test ant=2 (as before which is not 52)
refant=options.refant
#refant='Tile071' #As of 25/03/2015
#refant='Tile012' #Specifically for processing on 9/06/15
#To-do: make refant an input, otherwise default to Tile013


# Overwrite files
clobber=True
# Option to include the spectral index of the primary beam
spectral_beam=False
# Option to add more sources to the field
subcalibrator=False

#db=schedule.getdb()

# Get the frequency information of the measurement set
ms.open(vis)
rec = ms.getdata(['axis_info'])
df,f0 = (rec['axis_info']['freq_axis']['resolution'][len(rec['axis_info']['freq_axis']['resolution'])/2],rec['axis_info']['freq_axis']['chan_freq'][len(rec['axis_info']['freq_axis']['resolution'])/2])
F =rec['axis_info']['freq_axis']['chan_freq'].squeeze()/1e6
df=df[0]*len(rec['axis_info']['freq_axis']['resolution'])
f0=f0[0]
rec_time=ms.getdata(['time'])
sectime=qa.quantity(rec_time['time'][0],unitname='s')
midfreq=str(f0/1.e6)+'MHz'
bandwidth=str(df)+'Hz'

if spectral_beam:
# Start and end of the channels so we can make the spectral beam image
  startfreq=str((f0-df/2)/1.e6)+'MHz'
  endfreq=str((f0+df/2)/1.e6)+'MHz'
  freq_array=[midfreq,startfreq,endfreq]
else:
  freq_array=[midfreq]

# Get observation number directly from the measurement set
tb.open(vis+'/OBSERVATION')
MWA_GPS_TIME=tb.getcol('MWA_GPS_TIME')
print MWA_GPS_TIME 
#if type(MWA_GPS_TIME) is list: #Use info from first obs
#    obsnum=int(MWA_GPS_TIME[0])
#else:
obsnum=int(MWA_GPS_TIME[0]) #Does this work for single obs in ms??
tb.close
print obsnum
#info=mwapy.get_observation_info.MWA_Observation(obsnum,db=db)
#print 'Retrieved observation info for %d...\n%s\n' % (obsnum,info)

#schedule.tempdb.close()

# Calibrator information
#if info.calibration:
#  calibrator=info.calibrators
#else:
# Observation wasn't scheduled properly so calibrator field is missing: try parsing the fieldname
# assuming it's something like 3C444_81
  #calibrator=info.filename.rsplit('_',1)[0]
#calibrator=info.filename.rsplit('_')[0] #TMC: Take first string prior to _

print 'Calibrator is %s...' % calibrator

# subcalibrators not yet improving the calibration, probably due to poor beam model
if subcalibrator and calibrator=='PKS0408-65':
  subcalibrator='PKS0410-75'
elif subcalibrator and calibrator=='HerA':
  subcalibrator=False #TMC: don't use subcal yet
  #subcalibrator='3C353'
else:
  subcalibrator=False

print 'Subcalibrator is %s'%subcalibrator
# Start models are imagefreq Jy/pixel fits files in a known directory
model=modeldir+calibrator+'.fits'
# With a corresponding spectral index map
spec_index=modeldir+calibrator+'_spec_index.fits'
if not os.path.exists(spec_index):
    print 'Could not find spectral index map: %s'%spec_index
    print 'Using -0.83 for Hydra A'
    #Create uniform spectral map same size as HydrA image
    immath(imagename=[model],mode='evalexpr',outfile=spec_index[:-5]+'.im',
           expr='(IM0*0-0.83)')
    exportfits(fitsimage=spec_index,imagename=spec_index[:-5]+'.im',overwrite=clobber)
    print 'Exported to %s'%spec_index
    spec_index=modeldir+calibrator+'_spec_index.fits'

print 'Using spectral index map: %s'%spec_index 

if not os.path.exists(model):
  print 'Could not find calibrator model %s' % model
  raise KeyboardInterrupt

#Get centre frequency of model 
#importfits(fitsimage=model,imagename='test.im')

try:
    # See if there is a corresponding im file
    model_im=modeldir+calibrator+'.im'
    imagefreq=imhead(model_im,mode='get',hdkey='crval3')['value'] #Freq in Hz
except:
    print "Could not find image frequency"
    raise KeyboardInterrupt
print 'Image frequency is %s'%imagefreq
#  imhead(imagename=outname,mode='put',hdkey='crval3',hdvalue='150MHz')

#===============================================================================
# # Generate the primary beam
# delays=info.delays
# str_delays=','.join(map(str,delays))
# print 'Delays are: %s' % str_delays
#===============================================================================

# do this for the start, middle, and end frequencies
for freq in freq_array:
# We'll generate images in the local directory at the right frequency for this ms
  print calibrator
  print freq
  outname=calibrator+'_'+freq+'.im' #This is the name for the model image
  outnt2=calibrator+'_'+freq+'_nt2.im'
  print 'Generating image %s for calibration' % (outname)
  print 'Generating 2nd-order term image %s for calibration' % (outnt2)
# import model, edit header so make_beam generates the right beam in the right place
  if os.path.exists(outname) and clobber:
    print 'Overwriting %s'%outname
    rmtables(outname)
    #Why don't we remove outnt2?

  importfits(fitsimage=model,imagename=outname)
  imhead(outname,mode='put',hdkey='crval3',hdvalue=freq)
  imhead(outname,mode='put',hdkey='cdelt3',hdvalue=bandwidth)
  #TMC: the qa.time output is broken and causes an error 
  #imhead(outname,mode='put',hdkey='date-obs',hdvalue=qa.time(sectime,form=["ymd"])[0]) 
   
  #=============================================================================
  # exportfits(fitsimage=outname+'.fits',imagename=outname,overwrite=clobber)
  # print 'Creating primary beam models...'
  # subprocess.call(['python',bindir+'make_beam.py','-f',outname+'.fits','-d',str_delays])
  #=============================================================================
  
# delete the temporary model
#  rmtables(outname)

#===============================================================================
#  beamimage={}
#  fitsimage={}
#  for stokes in ['XX','YY']:
# # import the beams from make_beam.py into beamimage dictionary (for XX and YY)
#        fitsimage[stokes]=calibrator+'_'+freq+'.im_beam'+stokes+'.fits'
#        beamimage[stokes]=calibrator+'_'+freq+'_beam'+stokes+'.im'
#        if os.path.exists(beamimage[stokes]) and clobber:
#          rmtables(beamimage[stokes])
#        importfits(fitsimage=fitsimage[stokes],imagename=beamimage[stokes],
#                   overwrite=clobber)
#===============================================================================

# scale by the primary beam
# Correct way of doing this is to generate separate models for XX and YY
# Unfortunately, ft doesn't really understand cubes
# So instead we just use the XX model, and then scale the YY solution later

#freq=midfreq
#outname=calibrator+'_'+freq+'.im'
#outnt2=calibrator+'_'+freq+'_nt2.im'

#===============================================================================
# beamarray=[calibrator+'_'+freq+'_beamXX.im',calibrator+'_'+freq+'_beamYY.im']
# 
# # Hardcoded to use the XX beam in the model
# beam=calibrator+'_'+freq+'_beamXX.im'
# ratio=calibrator+'_'+freq+'_beam_ratio.im'
# # divide to make a ratio beam, so we know how to scale the YY solution later
# if os.path.exists(ratio) and clobber:
#	rmtables(ratio)
# immath(imagename=beamarray,mode='evalexpr',expr='(IM0/IM1)',outfile=ratio)
# ratio=imstat(ratio)['mean'][0]
#===============================================================================

if os.path.exists(outname) and clobber:
    rmtables(outname)

# Models are at 150MHz
# Generate scaled image at correct frequency
#exp='IM0/((150000000/'+str(f0)+')^(IM1))'
exp='IM0/(('+str(imagefreq)+'/'+str(f0)+')^(IM1))'

#Do maths on image
print 'Evaluating expression %s'%exp
print 'IM0 is %s'%model
print 'IM1 is %s'%spec_index 
immath(imagename=[model,spec_index],mode='evalexpr',expr=exp,
       outfile=outname)
#===============================================================================
# exp='IM2*IM0/((150000000/'+str(f0)+')^(IM1))' #beam*model/(150MHz/freq)^spec_index
# if os.path.exists(outname) and clobber:
#	rmtables(outname)
# immath(imagename=[model,spec_index,beam],mode='evalexpr',expr=exp,
#       outfile=outname)
#===============================================================================
print 'sectime2', sectime
imhead(outname,mode='put',hdkey='crval3',hdvalue=freq)
imhead(outname,mode='put',hdkey='cdelt3',hdvalue=bandwidth)
imhead(outname,mode='put',hdkey='date-obs',hdvalue=qa.time(sectime,form=["ymd"])[0])
imhead(outname,mode='put',hdkey='crval4',hdvalue='I')

# Generate 2nd Taylor term
if os.path.exists(outnt2) and clobber:
    rmtables(outnt2)

if spectral_beam:
# Generate spectral image of the beam
  exp='log(IM0/IM1)/log('+str(f0-df/2)+'/'+str(f0+df/2)+')'
  beam_spec=calibrator+'_'+startfreq+'--'+endfreq+'_beamXX.im'
  immath(imagename=[calibrator+'_'+startfreq+'_beamXX.im',calibrator+'_'+endfreq+'_beamXX.im'],
        mode='evalexpr',expr=exp,outfile=beam_spec)

  immath(imagename=[outname,beam,spec_index,beam_spec],mode='evalexpr',outfile=outnt2, 
       expr='(IM0*IM1*(IM2+IM3))')
else:
  #=============================================================================
  # immath(imagename=[outname,beam,spec_index],mode='evalexpr',outfile=outnt2, 
  #     expr='(IM0*IM1*IM2)')
  #=============================================================================
    immath(imagename=[outname,spec_index],mode='evalexpr',outfile=outnt2, 
       expr='(IM0*IM1)')

imhead(outnt2,mode='put',hdkey='crval3',hdvalue=freq)
imhead(outnt2,mode='put',hdkey='cdelt3',hdvalue=bandwidth)
imhead(outnt2,mode='put',hdkey='date-obs',hdvalue=qa.time(sectime,form=["ymd"])[0])
imhead(outnt2,mode='put',hdkey='crval4',hdvalue='I')

#Export so we can easily see what our models were
exportfits(fitsimage=outname+'.fits',imagename=outname,overwrite=clobber)
exportfits(fitsimage=outnt2+'.fits',imagename=outnt2,overwrite=clobber)

print 'Fourier transforming model...' #This applies it to the model column of the ms
ft(vis=vis,model=[outname,outnt2],nterms=2,usescratch=True)
#
##----------------- subcalibrator section -----------------------------
##----------------- not used for single-source calibration! -----------
## For some sources, add another source to the sky model
#
#if subcalibrator:
#  
## Start models are imagefreq Jy/pixel fits files in a known directory
#  model=modeldir+subcalibrator+'.fits'
## With a corresponding spectral index map
#  spec_index=modeldir+subcalibrator+'_spec_index.fits'
#
## We'll generate images in the local directory at the right frequency for this ms
#  outname=subcalibrator+'_'+freq+'.im'
#  outnt2=subcalibrator+'_'+freq+'_nt2.im'
#
## import model, edit header so make_beam generates the right beam in the right place
#  importfits(fitsimage=model,imagename=outname)
#  imhead(outname,mode='put',hdkey='crval3',hdvalue=freq)
#  imhead(outname,mode='put',hdkey='cdelt3',hdvalue=bandwidth)
#  imhead(outname,mode='put',hdkey='date-obs',hdvalue=qa.time(sectime,form=["ymd"])[0])
#  exportfits(fitsimage=outname+'.fits',imagename=outname)
## delete the temporary model
#  rmtables(outname)
#
#  subprocess.call(['python',bindir+'make_beam.py','-f',outname+'.fits','-d',str_delays])
#
## This is the subcalibrator, so we just use the XX beam and don't worry about the ratio
#
#  stokes='XX'
## import the beams from make_beam.py
#  fitsimage[stokes]=subcalibrator+'_'+freq+'.im_beam'+stokes+'.fits'
#  beamimage[stokes]=subcalibrator+'_'+freq+'_beam'+stokes+'.im'
#  importfits(fitsimage=fitsimage[stokes],imagename=beamimage[stokes])
#  beam=subcalibrator+'_'+freq+'_beamXX.im'
#
## Models are at imagefreq
## Generate scaled image at correct frequency
#  exp='IM2*IM0/(('+str(imagefreq)+'/'+str(f0)+')^(IM1))'
##  exp='IM2*IM0/((150000000/'+str(f0)+')^(IM1))'
#  immath(imagename=[model,spec_index,beam],mode='evalexpr',expr=exp,outfile=outname)
#  imhead(outname,mode='put',hdkey='crval3',hdvalue=freq)
#  imhead(outname,mode='put',hdkey='cdelt3',hdvalue=bandwidth)
#  imhead(outname,mode='put',hdkey='date-obs',hdvalue=qa.time(sectime,form=["ymd"])[0])
#  imhead(outname,mode='put',hdkey='crval4',hdvalue='I')
#
## Generate 2nd Taylor term
#  immath(imagename=[outname,spec_index,beam],mode='evalexpr',outfile=outnt2, expr='(IM2*IM1*IM0)')
#  imhead(outnt2,mode='put',hdkey='crval3',hdvalue=freq)
#  imhead(outnt2,mode='put',hdkey='cdelt3',hdvalue=bandwidth)
#  imhead(outnt2,mode='put',hdkey='date-obs',hdvalue=qa.time(sectime,form=["ymd"])[0])
#  imhead(outnt2,mode='put',hdkey='crval4',hdvalue='I')
#
#  print 'Fourier transforming secondary model...'
#  ft(vis=vis,model=[outname,outnt2],nterms=2,usescratch=True,incremental=True)
#
##----------------------------------------------------------------------------------

multi_ms=False #To fix up properly
if multi_ms:
    uvrange='>0.05klambda'
    print 'Bandpass calibrating with refant %s and uvrange %s over all obs ids'%(refant, uvrange)
    print 'Writing to caltable %s'%caltable #Simply use last caltable name
    if exclude_AAVS:
        print 'Excluding Tile079 from the bandapss calibration'
        bandpass(vis=vis,caltable=caltable,refant=refant,uvrange=uvrange,antenna='!Tile079')#,combine='obs')
    else:
        bandpass(vis=vis,caltable=caltable,refant=refant,uvrange=uvrange)#,combine='obs')
else:
    uvrange='%i~%ilambda'%(uvdist_low,uvdist_high)  #'>0.03klambda'
    print 'Bandpass calibrating with refant %s and uvrange %s'%(refant, uvrange)
    if exclude_AAVS:
        print 'Excluding Tile079 from the bandapss calibration'
        bandpass(vis=vis,caltable=caltable,refant=refant,uvrange=uvrange,antenna='!Tile079')
    else:
        bandpass(vis=vis,caltable=caltable,refant=refant,uvrange=uvrange)

#===============================================================================
# # Scale YY solution by the ratio
# tb.open(caltable)
# G = tb.getcol('CPARAM')
# tb.close()
# 
# new_gains = n.empty(shape=(shape(G)), dtype=complex128)
# 
# # XX gains stay the same
# new_gains[0,:,:]=G[0,:,:]
# # YY gains are scaled
# new_gains[1,:,:]=ratio*G[1,:,:]
# 
# # Copy to new calibration table -- for now
# #new_caltable=re.sub('.cal','_test.cal',caltable)
# #shutil.copytree(caltable,new_caltable)
# 
# tb.open(caltable,nomodify=False)
# tb.putcol('CPARAM',new_gains)
# tb.close()
# print 'Created %s!' % caltable
#===============================================================================
