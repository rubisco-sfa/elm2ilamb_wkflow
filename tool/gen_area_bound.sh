#!/usr/bin/env bash


module load nco
# ncfile: one of the land/atm/ocean history file

ncfile=$1
dirnfx=$2


ncks -O -v area,landfrac,topo $ncfile  $dirnfx/atm_area_landfrac.nc
#ncwa -a time $dirnfx/temp.nc -o $dirnfx/atm_area_landfrac.nc
#/bin/rm -f $dirnfx/temp.nc


# for land model, vertical soil layer
ncks -h -O -v lat,lon,levgrnd $ncfile x.nc

ncap2 -h -O -s 'defdim("nbnd", 2); lat_bnds=double(make_bounds(lat, $nbnd, "lat_bnds")); lon_bnds=double(make_bounds(lon, $nbnd, "lon_bnds"));' x.nc y.nc

cat <<EOF > depth.nco
levgrnd_bnds[\$levgrnd,\$nbnd]=double(0);
levgrnd_bnds[\$levgrnd,\$nbnd] = {
  0.0000000000000000, 0.0175110604614019,
  0.0175110604614019, 0.0450872629880905,
  0.0450872629880905, 0.0905527323484421,
  0.0905527323484421, 0.16551262140274,
  0.1655126214027400, 0.289100587368011,
  0.2891005873680110, 0.492862671613693,
  0.4928626716136930, 0.828809559345245,
  0.8288095593452450, 1.38269233703613,
  1.3826923370361300, 2.29589080810547,
  2.2958908081054700, 3.80150032043457,
  3.8015003204345700, 6.2838306427002,
  6.2838306427002000, 10.3765020370483,
  10.376502037048300, 17.1241760253906,
  17.124176025390600, 28.2492084503174,
  28.249208450317400, 42.0989685058594 };
EOF

ncap2 -S depth.nco y.nc $dirnfx/bounds.nc
ncatted -a bounds,levgrnd,c,c,levgrnd_bnds $dirnfx/bounds.nc

# remove bounds attributes
ncatted -O -h -a ,lat_bnds,d,, $dirnfx/bounds.nc
ncatted -O -h -a ,lon_bnds,d,, $dirnfx/bounds.nc
ncatted -O -h -a ,levgrnd_bnds,d,, $dirnfx/bounds.nc

# remove the history record 
ncatted -a history,global,o,c, $dirnfx/bounds.nc


# cleanup
/bin/rm -f x.nc y.nc depth.nco

