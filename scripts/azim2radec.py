import sys
import math

from astropy.time import Time
from astropy import units as u
from astropy.coordinates import SkyCoord, EarthLocation, AltAz, ICRS, FK5, FK4
MWA_POS=EarthLocation.from_geodetic(lon="116:40:14.93",lat="-26:42:11.95",height=377.8)

DEG2RAD = (math.pi/180.00)
RAD2DEG = (180.00/math.pi)

# https://python.hotexamples.com/examples/astropy.coordinates/AltAz/-/python-altaz-class-examples.html
# def azel2radec(az_deg, el_deg, lat_deg, lon_deg, dtime):
#    obs = EarthLocation(lat=lat_deg * u.deg, lon=lon_deg * u.deg)
#    direc = AltAz(location=obs, obstime=Time(dtime),
#                  az=az_deg * u.deg, alt=el_deg * u.deg)
#    sky = SkyCoord(direc.transform_to(ICRS()))
#    return sky.ra.deg, sky.dec.deg
# t0 = Time("%d-%02d-%02d 00:00:00" % (year, month, day), format = 'iso', scale = 'utc')
def azim2radec( az_deg, el_deg, dtime, geo_lat=-26.70331944444445, debug=True, astro_azim=True ) : 
   # obstime=Time(dtime)
   fk5_2000 = FK5(equinox=Time(2000, format='jyear'))
   fk4_2000 = FK4(equinox=Time(2000, format='jyear'))
   direc = AltAz(location=MWA_POS, obstime=dtime, az=az_deg * u.deg, alt=el_deg * u.deg)
   sky = SkyCoord(direc.transform_to(ICRS()))
#   sky = SkyCoord(direc.transform_to(fk4_2000))

   print("DEBUG : ra, dec = %.6f, %.6f [deg]" % (sky.ra.deg, sky.dec.deg))
  
   return ( sky.ra.deg, sky.dec.deg, azim_deg, elev_deg, geo_lat )   

if __name__=="__main__":
   azim_deg = 0.00
   if len(sys.argv) > 1:
       azim_deg = float( sys.argv[1] )

   elev_deg = 90.00
   if len(sys.argv) > 2:
       elev_deg = float( sys.argv[2] )

   dtime="2023-06-01 10:36:21.900"
#   lst_hours = 0.00
   if len(sys.argv) > 3:
       dtime = sys.argv[3]
       
   if dtime[8] == "T" :
      # 20230601T103621900
      year=dtime[0:4]    
      mon=dtime[4:6]
      day=dtime[6:8]
      h=dtime[9:11]
      m=dtime[11:13]
      s=dtime[13:15] + "." + dtime[15:]
      dtime_new=("%s-%s-%s %s:%s:%s" % (year,mon,day,h,m,s))
      print("DEBUG : %s -> %s" % (dtime,dtime_new))
      dtime = dtime_new
       
   geo_lat = MWA_POS.lat.value
   if len(sys.argv) > 4:
      geo_lat = float( sys.argv[4] )
      
   print("DEBUG : before call of azim2radec ?")   
   azim2radec( azim_deg, elev_deg, dtime, geo_lat )   
