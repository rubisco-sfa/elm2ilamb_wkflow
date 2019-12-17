#!/usr/bin/env bash

#-set -x
# This script is used to remap ne grid to regular grid and cannot be run as
# a standalone mode since some variables are defined in the script that source
# this script

# get from clm_singlevar_ts, including dst_grd, src_grd
# nvrs gotten from ts generation either ncclimo or pyreshaper

cmip6_opt='-7 --dfl_lvl=1 --no_cll_msr --no_frm_trm --no_stg_grd' # CMIP6-specific options


#debug
#-drc_map=/global/cscratch1/sd/minxu/ILAMB_WCYCLE_20190319/hires_prc/theta.20180906.branch_noCNT.A_WCYCL1950S_CMIP6_HR/map/
#-drc_out=/global/cscratch1/sd/minxu/ILAMB_WCYCLE_20190319/hires_prc/theta.20180906.branch_noCNT.A_WCYCL1950S_CMIP6_HR/org/
#-drc_tmp=/global/cscratch1/sd/minxu/ILAMB_WCYCLE_20190319/hires_prc/theta.20180906.branch_noCNT.A_WCYCL1950S_CMIP6_HR/tmp/
#-drc_log=/global/cscratch1/sd/minxu/ILAMB_WCYCLE_20190319/hires_prc/theta.20180906.branch_noCNT.A_WCYCL1950S_CMIP6_HR/log/
#-drc_rgr=/global/cscratch1/sd/minxu/ILAMB_WCYCLE_20190319/hires_prc/theta.20180906.branch_noCNT.A_WCYCL1950S_CMIP6_HR/rgr/
#-skip_genmap=651


module load ncl/6.4.0  # for esmf regridded
module load nco

export NCO_PATH_OVERRIDE='No'

cd ${drc_out}
echo $DATA
echo $drc_map


bgn_year=$stryear
end_year=$endyear
alg_year=$year_align

# get from run_gen_ts including drc_inp, drc_out, drc_tmp and drc_map

use_mynco=1
if [[ $use_mynco == 1 ]]; then
   export NCO_PATH_OVERRIDE='No'
   myncremap=$SrcDir/tool/ncremap

else
   myncremap=ncremap
fi

echo "begin of remapping"
firstyr=`printf "%04d" $((bgn_year+alg_year))`


xskip_genmap=$skip_genmap

if [[ $cmp == "atm" ]]; then
   xskip_genmap= 0
fi


if [[ x$xskip_genmap == "x0" ]]; then
    echo "do mapping"

    if [[ $comp == "lnd" ]]; then
       $myncremap -a aave -P sgs -s $src_grd -g $dst_grd -m ${drc_map}/map_${comp}_${BASHPID}.nc --drc_out=${drc_tmp} \
                            ${drc_inp}/*.clm2.h0.${firstyr}-01.nc > ${drc_log}/ncremap.lnd 2>&1

    else
       $myncremap -a aave -s $src_grd -g $dst_grd -m ${drc_map}/map_${comp}_${BASHPID}.nc --drc_out=${drc_tmp} \
                            ${drc_inp}/*.cam.h0.${firstyr}-01.nc > ${drc_log}/ncremap.lnd 2>&1
    fi
    if [[ $? != 0 ]]; then
       echo "Failed in the ncreamp, please check out ${drc_log}/ncremap.lnd"
       exit
    fi
    mapid=$BASHPID
else
    mapid=$skip_genmap
fi

#seperate files to two groups 
smallfiles=()
largefiles=()



# the fldlist_monthly can have the ilamb varaible list or just the case name to remap the whole h0 output
varlist=(${fldlist_monthly})

for lvr in "${varlist[@]}"; do
    echo $lvr
    smallfiles+=(`cd ${drc_out} && find ./ -name "${lvr}*.nc" -type f -size -1000000k -follow`)
    largefiles+=(`cd ${drc_out} && find ./ -name "${lvr}*.nc" -type f -size +1000000k -follow`)
done


#mxu temporialy fix
#-largefiles=()
#-smallfiles=(`cd ${drc_out} && find ./ -name "${lvr}*.nc" -type f -size +1000000k -follow`)

echo "${#largefiles[@]}"
echo "${#smallfiles[@]}"

numcc_remap=3
if [[ ${#smallfiles[@]} -lt $numcc_remap ]]; then
   numcc_remap=${#smallfiles[@]}
fi

# small files
numsmallfls=${#smallfiles[@]}
#
if [[ $((numsmallfls % numcc_remap)) == 0 ]]; then
   nseq=$((numsmallfls/numcc_remap+0))
else
   nseq=$((numsmallfls/numcc_remap+1))
fi

echo $nseq

remap_pid=()
for iseq in `seq 1 $numcc_remap`; do
    is=$((iseq*nseq-nseq))
    it=$((is+nseq))
    ie=$(($it>$numsmallfls?$numsmallfls:$it))
    iv=$((ie-is))   # not include ie
    filelst=("${smallfiles[@]:$is:$iv}")
    echo ${filelst[*]}
    if [[ $iv -lt 0 ]]; then
        break
    else
        export TMPDIR=${drc_tmp}
        /bin/ls ${filelst[@]} | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${comp}_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
        remap_pid+=($!)
    fi
done

#collect them waiting for them to end
for pid in "${remap_pid[@]}"; do
    echo $pid
    wait $pid
done

# large files
remap_pid=()
date
for lf in "${largefiles[@]}"; do
    for im in `seq 0 11`; do
        echo $im $lf
        ncks -h -d time,$im,,12 $lf ${drc_tmp}/tmp$im.nc &
        remap_pid+=($!)
    done

    for pid in "${remap_pid[@]}"; do
        echo $pid
        wait $pid
    done
    bname=`basename $lf`

    date
    /bin/ls ${drc_tmp}/tmp[0-3].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
    /bin/ls ${drc_tmp}/tmp[4-6].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
    /bin/ls ${drc_tmp}/tmp[7-9].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
    /bin/ls ${drc_tmp}/tmp1[0-1].nc | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
    wait

    date
    # combine
    ncrcat -h ${drc_rgr}/tmp*.nc -o ${drc_rgr}/$bname
    /bin/rm -f ${drc_rgr}/tmp*.nc
    /bin/rm -f ${drc_tmp}/tmp*.nc
    date
done

date >> logtime
echo "end of remapping"


