#!/bin/bash


# Author: Min Xu
# @ORNL

# Modification history:
# Required software: NCO toolkit 


ilamb_fields=0        # define varaible list for ILAMB
compress=1            # 1 - compress; 0 - noncompress
convert_to_cmip=0     # 0 - group monthly files to century files; 1 - further convert them following the cmip convention 
nconcurrent=6         # number of concurrent processes to run, more = faster
add_fixed_flds=0      # default, the fx fields won't be generated



SrcDir=`pwd`

CmdDir=`which clm_to_mip 2>/dev/null`

if [[ ! -z "$CmdDir" ]]; then
   SrcDir=`dirname $CmdDir`
fi                        


cmdname=`basename $0`
printusage="$cmdname --caseid[-c] --centuries[-T] --year_range[-y] --caseidpath[-i] --outputpath[-o] \n --experiment[-e] --model[-m] --numcc [--cmip] [--ilamb] [--addfxflds] -v"


if [[ $# == 0 ]]; then
   echo $printusage
   exit 1
fi


# command line arguments:


longargs=ilamb,cmip,addfxflds,caseid:,centuries:,year_range:,caseidpath:,outputpath:,experiment:,model:,numcc: 
shrtargs=hvc:T:y:i:o:e:m:
CmdLine=`getopt -s bash  -o  $shrtargs --long $longargs -- "$@"`

if [[ $? != 0 ]]; then 
  echo "Terminating..." >/dev/stderr
  exit 1
fi

eval set -- "$CmdLine"

while true; do
      case "$1" in
        -h) echo $printusage; exit 1; shift ;;
        -v) set -x; shift ;;
	-c|--caseid)
                caseid=$2
		echo "The case name: $2"; shift 2 ;;
	-T|--centuries)
                centuries=`echo $2 | sed 's/,/ /g'`
		echo "The case simulated centuries: "\`$2:q\' $centuries; shift 2 ;;
	-y|--year_range)
                year_range=$2
		echo "The simulated year range: "\`$2:q\'; shift 2 ;; 
	-i|--caseidpath)
                caseidpath=`readlink -f $2`
		echo "The directory of the case results: "\`$2:q\' ; shift ;;
	-o|--outputpath)
                outputpath=`readlink -f $2`
		echo "The output directory: "\`$2:q\'; shift ;;
        -e|--experiment)
                experiment=$2
		echo "The experiment name: "\`$2:q\' ; shift ;;
        -m|--model)
                model=$2
		echo "The model name: "\`$2:q\' ; shift 2 ;;
        --numcc)
                nconcurrent=$2
		echo "Number of concurrent processes: $2"; shift 2 ;;
        --ilamb)
                ilamb_fields=1; shift ;;
        --cmip)
                convert_to_cmip=1; shift ;;
        --addfxflds)
                add_fixed_flds=1; shift ;;
	--) shift; break ;;
	*) echo "Internal error!"; exit 1 ;;

      esac
done



echo $ilamb_fields
echo $convert_to_cmip
echo $add_fixed_flds


if [[ ! -f clm_to_mip && $convert_to_cmip == 1 ]]; then
   echo "clm_to_mip is needed for converting model outputs following cmip conventions" 
fi

#exit
exit 2;

if [[ ! -d $outputpath ]]; then
   mkdir -p $outputpath
fi

if [[ ! -d $outputpath/$caseid ]]; then
   mkdir $outputpath/$caseid
fi

cd $outputpath/$caseid

if [[ $ilamb_fields == 1 ]]; then 
  fldlist_monthly=(ALT AR BTRAN CH4PROD DENIT EFLX_LH_TOT ELAI ER ESAI FAREA_BURNED \
    FCEV FCH4 FCH4TOCO2 FCOV FCTR FGEV FGR FGR12 FH2OSFC FINUNDATED FIRA FIRE FLDS FPG FPI \
    FPSN FROST_TABLE FSA FSAT FSDS FSH FSM FSNO FSR F_DENIT F_NIT GPP \
    GROSS_NMIN H2OSFC H2OSNO HR HTOP LAND_USE_FLUX LEAFC FROOTC NDEP_TO_SMINN NBP NEE NEP \
    NET_NMIN NFIX_TO_SMINN NPP Q2M QCHARGE QDRAI QOVER QRUNOFF QRGWL QSNOMELT \
    QSOIL QVEGE QVEGT RAIN RH2M SMIN_NO3 SMIN_NH4 SNOW SNOWDP SNOWICE SNOWLIQ SNOW_DEPTH \
    SNOW_SINKS SNOW_SOURCES SOMHR TG TSA TSAI TLAI TV QBOT TBOT \
    AGNPP FROOTC_ALLOC LEAFC_ALLOC WOODC_ALLOC WOOD_HARVESTC \
    CH4_SURF_AERE_SAT CH4_SURF_AERE_UNSAT CH4_SURF_DIFF_SAT \
    CH4_SURF_DIFF_UNSAT CH4_SURF_EBUL_SAT CH4_SURF_EBUL_SAT CONC_CH4_SAT \
    CONC_CH4_UNSAT FCH4_DFSAT MR TOTCOLCH4 ZWT_CH4_UNSAT \
    FSDSND FSDSNI FSDSVD FSDSVI \
    TWS VOLR WA ZWT_PERCH ZWT WIND COL_FIRE_CLOSS \
    F_DENIT_vr F_NIT_vr H2OSOI O_SCALAR SOILICE SOILLIQ SOILPSI TLAKE TSOI T_SCALAR W_SCALAR  \
    SOIL1N SOIL2N SOIL3N SOIL1C SOIL2C SOIL3C TOTVEGC TOTVEGN TOTECOSYSC TOTLITC TOTLITC_1m \
    TOTLITN_1m TOTSOMC TOTSOMC_1m TOTSOMN_1m CWDC PBOT)

  fldlist_annual=( )
else
  fldlist_monthly=(ALT FCH4 FAREA_BURNED EFLX_LH_TOT FH2OSFC LAND_USE_FLUX H2OSOI NBP NEE \
    NPP Q2M RAIN SNOW SNOWDP SNOW_DEPTH TWS VOLR ZWT TSA RH2M QRUNOFF QOVER QDRAI FSNO TSOI \
    TLAI TSAI ELAI ESAI FSH FSDS FSA FIRE FIRA LEAFC TOTSOMC TOTSOMC_1m TOTVEGC TOTECOSYSC \
    TLAKE CWDC COL_FIRE_CLOSS WOOD_HARVESTC GPP ER NEP QSOIL QVEGE QVEGT QRGWL QSNOMELT)
  fldlist_annual=( )
fi

# time-serialization
  source ./gen_run_ts.bash



# convert to CMIP format
if ($convert_to_cmip == 1) then
   #cp /glade/u/home/dlawren/bin/clm_to_mip .

   #mxu add
   #/bin/cp -f /lustre/atlas1/cli106/proj-shared/mxu/ILAMB/clm_to_mip $outputpath/$caseid/
   #/bin/cp -f /lustre/atlas1/cli106/proj-shared/mxu/ALM_ILAMB/alm2lamb_wkflow/clm_to_mip $outputpath/$caseid/
   /bin/cp -f $SrcDir/clm_to_mip $outputpath/$caseid/
   cd $outputpath/$caseid/
   echo clm_to_mip ${model} ${experiment} ${year_range}
   ./clm_to_mip ${model} ${experiment} ${year_range}
endif

#setenv email_address  ${LOGNAME}@ucar.edu
#echo `date` $caseid > email_msg2
#echo MESSAGE FROM clm_singlevar_ts.csh >> email_msg2
#echo YOUR TIMESERIES FILES ARE NOW READY! >> email_msg2
#mail -s 'clm_singlevar_ts.csh is complete' $email_address < email_msg2
#echo E_MAIL SENT
#'rm' email_msg2

echo Done
