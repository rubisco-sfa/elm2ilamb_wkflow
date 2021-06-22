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
#module load ncl  # for esmf regridded
module load nco


# ncdmnsz $dmn_nm $fl_nm : What is dimension size?
function ncdmnsz { ncks --trd -m -M ${2} | grep -E -i ": ${1}, size =" | cut -f 7 -d ' ' | uniq ; }

export NCO_PATH_OVERRIDE='No'

cd ${drc_out}


if [[ $mydebug == 1 ]]; then
  echo $DATA
  echo $drc_map
fi


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

echo "Begin remapping ..."

firstyr=`printf "%04d" $((bgn_year+alg_year))`


xskip_genmap=$skip_genmap

if [[ $cmp == "atm" ]]; then
   xskip_genmap= 0
fi


if [[ x$xskip_genmap == "x0" ]]; then
    echo "Generate remapping coefficients"

    if [[ $comp == "lnd" ]]; then
       echo "$myncremap -a aave -P sgs -s $src_grd -g $dst_grd -m ${drc_map}/map_${comp}_${BASHPID}.nc --drc_out=${drc_tmp} \
                            ${drc_inp}/*.clm2.h0.${firstyr}-01.nc" 
       $myncremap -a aave -P sgs -s $src_grd -g $dst_grd -m ${drc_map}/map_${comp}_${BASHPID}.nc --drc_out=${drc_tmp} \
                            ${drc_inp}/*.clm2.h0.${firstyr}-01.nc > ${drc_log}/ncremap.lnd 2>&1

    else
       echo "$myncremap -a aave -s $src_grd -g $dst_grd -m ${drc_map}/map_${comp}_${BASHPID}.nc --drc_out=${drc_tmp} \
                            ${drc_inp}/*.cam.h0.${firstyr}-01.nc"
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
    #-echo $lvr
    smallfiles+=(`cd ${drc_out} && find ./ -name "${lvr}_??????_??????.nc" -type f -size -1000000k -follow`)
    largefiles+=(`cd ${drc_out} && find ./ -name "${lvr}_??????_??????.nc" -type f -size +1000000k -follow`)
done


#mxu temporialy fix
#-largefiles=()
#-smallfiles=(`cd ${drc_out} && find ./ -name "${lvr}*.nc" -type f -size +1000000k -follow`)
#-smallfiles=()

echo -e "No. of large file to remap: ${CR_GRN}${#largefiles[@]}${CR_NUL}"
echo -e "No. of small file to remap: ${CR_GRN}${#smallfiles[@]}${CR_NUL}"

numcc_remap=3

echo -e "${FTBOLD}Attn: default no. of threads to be used in remapping is 3, it can be changed in run_ncremap.sh${FTNORM}"

if [[ ${#smallfiles[@]} -lt $numcc_remap ]]; then
   numcc_remap=${#smallfiles[@]}
fi

# small files
numsmallfls=${#smallfiles[@]}
#


if [[ $numsmallfls -gt 0 ]]; then
   if [[ $((numsmallfls % numcc_remap)) == 0 ]]; then
      nseq=$((numsmallfls/numcc_remap+0))
   else
      nseq=$((numsmallfls/numcc_remap+1))
   fi
   
   #echo $nseq
   
   
   remap_pid=()
   for iseq in `seq 1 $numcc_remap`; do
       is=$((iseq*nseq-nseq))
       it=$((is+nseq))
       ie=$(($it>$numsmallfls?$numsmallfls:$it))
       iv=$((ie-is))   # not include ie
       filelst=("${smallfiles[@]:$is:$iv}")
   
       if [[ $mydebug == 1 ]]; then
          echo ${filelst[*]}
       fi
   
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
   
       if  wait "$pid"; then
           echo "thread $pid ended successfully"
       else
           echo "thread $pid ended with errors or earlier"
       fi
   done
fi

# large files
#-date
for lf in "${largefiles[@]}"; do
    remap_pid=()
    ntimes=`ncdmnsz time $lf`

    if [[ $ntimes -gt 10 ]]; then
        nsects=$((ntimes/10+1))
    else
	nsects=1
    fi

    totjob=-1
    for im in `seq 0 9`; do
	
	ib=$((im*nsects))
	ie=$((im*nsects+nsects-1))


	if [[ $ib -gt $((ntimes-1)) ]]; then
           break
	else
           totjob=$((totjob+1))
           if [[ $ie -gt $((ntimes-1)) ]]; then
	      ie=$((ntimes-1))
	   fi
           echo $im $lf $ntimes $nsects $ib $ie $totjob
           ncks -h -d time,$ib,$ie,1 $lf ${drc_tmp}/tmp$im.nc &
           remap_pid+=($!)
	fi
    done

    for pid in "${remap_pid[@]}"; do
        #-echo $pid
        wait $pid
    done
    bname=`basename $lf`

    date

    if [[ $totjob -le 3 ]]; then
       /bin/ls ${drc_tmp}/tmp[0-$totjob].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${comp}_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
    else
       /bin/ls ${drc_tmp}/tmp[0-3].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${comp}_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
       if [[ $totjob -le 6 ]]; then
          /bin/ls ${drc_tmp}/tmp[4-$totjob].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${comp}_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
       else
          /bin/ls ${drc_tmp}/tmp[4-6].nc        | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${comp}_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
          /bin/ls ${drc_tmp}/tmp[7-$totjob].nc  | $myncremap -a aave ${cmip6_opt} -m ${drc_map}/map_${comp}_${mapid}.nc --drc_out=${drc_rgr} >> ${drc_log}/ncremap.lnd 2>&1 &
       fi
    fi
    wait

    date
    # combine
    ncrcat -h ${drc_rgr}/tmp*.nc -o ${drc_rgr}/$bname
    /bin/rm -f ${drc_rgr}/tmp*.nc
    /bin/rm -f ${drc_tmp}/tmp*.nc
    date
done

date >> logtime
echo "End of remapping"


