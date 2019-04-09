#!/usr/bin/env bash

#-#SBATCH -q debug
#-#SBATCH -N 1
#-#SBATCH -t 00:30:00
#-#SBATCH -J benchmark_ncclimo
#-#SBATCH -o my_job.o%j
#-#SBATCH -A m2467
#-#SBATCH --constraint=knl

# It cannot be used as a standalone mode, otherwise please 
# provide outputpath, caseid, caseidpath, stryear, endyear,
# year_align, numcc, fldlist_monthly

cmip6_opt='--netcdf_format="netcdf4" --compression_level=1'

DATA=$outputpath/$caseid
drc_inp=$caseidpath


drc_out=${DATA}/org # Native grid output directory
drc_rgr=${DATA}/rgr # Regridded output directory
drc_tmp=${DATA}/tmp # Temporary/intermediate-file directory
drc_map=${DATA}/map # Map directory
drc_log=${DATA}/log # Log directory


bgn_year=$stryear
end_year=$endyear

ntasks=$nconcurrent

if [[ ! -d $drc_out ]]; then
   mkdir -p $drc_out
fi
if [[ ! -d $drc_rgr ]]; then
   mkdir -p $drc_rgr
fi
if [[ ! -d $drc_tmp ]]; then
   mkdir -p $drc_tmp
fi
if [[ ! -d $drc_map ]]; then
   mkdir -p $drc_map
fi
if [[ ! -d $drc_log ]]; then
   mkdir -p $drc_log
fi


vars="$(echo -e "${fldlist_monthly}" | sed -e 's/ \+/,/g' | sed -e 's/,$//')"
nvrs="$(echo -e "$vars" | tr -cd , | wc -c)"; nvrs=$((nvrs+1))

cd ${drc_inp}
ncfiles=''
for iy in `seq $((bgn_year+year_align)) $((end_year+year_align))`; do
    cy=`printf "%04d" $iy`
    ncfiles="$ncfiles "`/bin/ls *clm2.h0.${cy}*.nc`
done

/bin/rm -f ${drc_out}/*.nc

s2smake --netcdf_format="netcdf4" --compression_level=1 \
        --output_prefix="$drc_out/pyreshaper." \
        --output_suffix="${year_range}.nc" -m "time" -m "time_bounds" \
        --time_series=$vars --specfile=${drc_log}/reshape.s2s ${ncfiles}

srun -n $ntasks s2srun --verbosity=0 ${drc_log}/reshape.s2s 

