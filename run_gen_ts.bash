#!/usr/bin/env bash

set -x

DATA=$outputpath/$caseid
drc_inp=$caseidpath
drc_out="${DATA}/org" # Native grid output directory
drc_rgr="${DATA}/rgr" # Regridded output directory
drc_tmp="${DATA}/tmp" # Temporary/intermediate-file directory
drc_map="${DATA}/map"
drc_log="${DATA}/log"


bgn_year=$stryear
end_year=$endyear

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


cmip6_opt='-7 --dfl_lvl=1 --no_cll_msr --no_frm_trm --no_stg_grd' # CMIP6-specific options
#spl_opt='--yr_srt=1 --yr_end=27 --ypf=27' # 2D+3D Splitter options


echo $fldlist_monthly

vars="$(echo -e "${fldlist_monthly}" | sed -e 's/ \+/,/g' | sed -e 's/,$//')"
nvrs="$(echo -e "$vars" | tr -cd , | wc -c)"

nvrs=$((nvrs+1))


printf "%s\n%s" "Processing variables:" $vars
echo "Total number of variables is: $nvrs"

echo $drc_inp, $drc_out, $drc_tmp 


     


export TMPDIR=${drc_tmp}
#/bin/rm ~/ncremap.lnd
# Create SGS map from first file, then split all files, then regrid all split files
# Applying SGS map on its own, outside of SGS mode, does not append correct area, sgs_frc, sgs_msk to output
# This is acceptable for single variable output timeseries (like CMIP6) that lack area, sgs_frc, sgs_msk
#-ncremap -a aave -P sgs -s $src_grd -g $dst_grd -m ${drc_map}/map_$BASHPID.nc --drc_out=${drc_rgr} ${drc_inp}/*.clm2.h0.$((bgn_year+year_align))-01.nc > ~/ncremap.lnd 2>&1

nseq=$((nvrs/24+1))

varlist=($fldlist_monthly)

for iseq in `seq 0 23`; do
    is=$((iseq*nseq))
    it=$((is+nseq))
    ie=$(($it>$nvrs?$nvrs:$it))
    iv=$((ie-is))
    vartemp=("${varlist[@]:$is:$iv}")
    echo $vartemp
    echo ${vartemp[@]/%/*.nc}
done
# Native Land

which ncclimo
export TMPDIR=${drc_tmp}
cd ${drc_inp}

echo $drc_inp
ncfiles=''
for iy in `seq $((bgn_year+year_align)) $((end_year+year_align))`; do
    ncfiles="$ncfiles "`/bin/ls *clm2.h0.${iy}*.nc`
done
echo $ncfiles

echo $$ -- $BASHPID

#-time /bin/ls *.clm2.h0.25[78][0-9]-*.nc *.clm2.h0.259[0-6]-*.nc | /global/homes/z/zender/bin_edison/ncclimo --var=${vars} --job_nbr=$nvrs --yr_str= --yr_end= --ypf=100 \
#-time /bin/ls $ncfiles | /global/homes/z/zender/bin_edison/ncclimo --var=${vars} --job_nbr=$nvrs --yr_srt=$bgn_year --yr_end=$end_year --ypf=100 \
#-${cmip6_opt} --drc_out=${drc_out} >> ~/ncclimo.lnd 2>&1

echo $$ -- $BASHPID

# Regrid Land
#-export TMPDIR=${drc_tmp};cd ${drc_out};/bin/ls *_000101_001012.nc | ncremap -a aave ${cmip6_opt} -m ${DATA}/maps/map_ne30np4_to_cmip6_180x360_sgs_elm.20190301.nc --drc_out=${drc_rgr} >> ~/ncremap.lnd 2>&1

cd ${drc_out};
date > logtime
#-export TMPDIR=${drc_tmp};cd ${drc_out};/bin/ls *.nc | \
#-       ncremap -a aave ${cmip6_opt} -m ${drc_map}/map_91431.nc -j 24 --drc_out=${drc_rgr} >> ~/ncremap.lnd 2>&1
#-date >> logtime

remap_pid=()
for iseq in `seq 0 23`; do
    is=$((iseq*nseq))
    it=$((is+nseq))
    ie=$(($it>$nvrs?$nvrs:$it))
    iv=$((ie-is))

    if [[ $iv -lt 0 ]]; then
        break
    else
        vartemp=("${varlist[@]:$is:$iv}")
        export TMPDIR=${drc_tmp};cd ${drc_out};/bin/ls ${vartemp[@]/%/*.nc} | \
        ncremap -a aave ${cmip6_opt} -m ${drc_map}/map_91431.nc --drc_out=${drc_rgr} >> ~/ncremap.lnd 2>&1 &
        remap_pid+=($!)
    fi
    echo $iseq
done


for pid in "${remap_pid[@]}"; do
    echo $pid
    wait $pid
done
date >> logtime
echo "end of remapping"
