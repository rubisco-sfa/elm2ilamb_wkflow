#!/usr/bin/env bash



# This script cannot be used as a standalone mode since some variables
# are defined in the script that sources this script

# If you do want to use it as a standalone mode, please define the following
# variables: outputpath, caseid, caseidpath, fldlist_monthly, stryear, endyear,
# etc.

cmip6_opt='-7 --dfl_lvl=1 --no_cll_msr --no_frm_trm --no_stg_grd' # CMIP6-specific options

#-DATA=$outputpath/$caseid
#-drc_inp=$caseidpath
#-drc_out=${DATA}/org # Native grid output directory
#-drc_rgr=${DATA}/rgr # Regridded output directory
#-drc_tmp=${DATA}/tmp # Temporary/intermediate-file directory
#-drc_map=${DATA}/map # Map directory
#-drc_log=${DATA}/log # Log directory
#-
#-if [[ ! -d $drc_out ]]; then
#-   mkdir -p $drc_out
#-fi
#-if [[ ! -d $drc_rgr ]]; then
#-   mkdir -p $drc_rgr
#-fi
#-if [[ ! -d $drc_tmp ]]; then
#-   mkdir -p $drc_tmp
#-fi
#-if [[ ! -d $drc_map ]]; then
#-   mkdir -p $drc_map
#-fi
#-if [[ ! -d $drc_log ]]; then
#-   mkdir -p $drc_log
#-fi


#force to decimal
bgn_year=$((10#$stryear))
end_year=$((10#$endyear))

use_mynco=2

if [[ $use_mynco == 1 ]]; then
   myncclimo=$SrcDir/tool/ncclimo
elif [[ $use_mynco == 2 ]]; then
   echo "use the system ncclimo"
   export NCO_PATH_OVERRIDE=No
   myncclimo=`which ncclimo`
else
   myncclimo=/global/u1/z/zender/bin_cori/ncclimo
fi


vars="$(echo -e "${fldlist_monthly}" | sed -e 's/ \+/,/g' | sed -e 's/,$//')"
nvrs="$(echo -e "$vars" | tr -cd , | wc -c)"; nvrs=$((nvrs+1))

if [[ "$mydebug" == 1 ]]; then
   echo $DATA, $drc_map
   echo $fldlist_monthly
   printf "%s\n%s" "Processing variables:" $vars
fi
echo -e "${CR_GRN}Total number of variables for time serialization is: $nvrs${CR_NUL}"

export TMPDIR=${drc_tmp}

cd ${drc_inp}

#generate the list of ncfiles not including directory information
ncfiles=''
for iy in `seq $((bgn_year+year_align)) $((end_year+year_align))`; do
    cy=`printf "%04d" $iy`

    if [[ $high_freq_data == 0 ]]; then
        ncfiles="$ncfiles "`/bin/ls *${comp}.h0.${cy}*.nc`
    else
        ncfiles="$ncfiles "`/bin/ls *${comp}.h0.${cy}*00000.nc`
    fi
done

if [[ "$mydebug" == 1 ]]; then
   echo $vars
fi


echo "Time serialization stats:"

export HDF5_USE_FILE_LOCKING=FALSE

if [[ $nconcurrent == 0 ]]; then
   if [[ $high_freq_data == 0 ]]; then
      time /bin/ls $ncfiles | $myncclimo --var=${vars} --job_nbr=$nvrs --yr_srt=$bgn_year --yr_end=$end_year --ypf=500 \
           ${cmip6_opt} --drc_out=${drc_out} > ${drc_log}/ncclimo.lnd 2>&1
   else
      time /bin/ls $ncfiles | $myncclimo --var=${vars} --job_nbr=$nvrs --yr_srt=$bgn_year --yr_end=$end_year --ypf=500 --clm_md='hfs'\
           ${cmip6_opt} --drc_out=${drc_out} > ${drc_log}/ncclimo.lnd 2>&1
   fi
else
   if [[ $high_freq_data == 0 ]]; then
      time /bin/ls $ncfiles | $myncclimo --var=${vars} --job_nbr=$nconcurrent --yr_srt=$bgn_year --yr_end=$end_year --ypf=500 \
           ${cmip6_opt} --drc_out=${drc_out} > ${drc_log}/ncclimo.lnd 2>&1
   else
      time /bin/ls $ncfiles | $myncclimo --var=${vars} --job_nbr=$nconcurrent --yr_srt=$bgn_year --yr_end=$end_year --ypf=500 --clm_md='hfs'\
           ${cmip6_opt} --drc_out=${drc_out} > ${drc_log}/ncclimo.lnd 2>&1
   fi
fi

if [ "$?" != 0 ]; then
   echo "Error in the ncclimo, exiting .."
   exit;
else

   if [[ $mydebug == 1 ]]; then
      echo $DATA, $drc_map
   fi
fi
