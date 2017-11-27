#!/bin/tcsh 



# Author: ??? who?

# Modification history:
# Required software: NCO toolkit 

# Min Xu: 2017-04-28: add command line arguments and clean codes
# Min Xu: 2017-12-27: add the --addfxflds to generate the fixed fields "areacella and sftlf"

# ATTN: the working directory is the output directory



set ilamb_fields = 0        # define varaible list for ILAMB
set compress = 1            # 1 - compress; 0 - noncompress
set convert_to_cmip = 0     # 0 - group monthly files to century files; 1 - further convert them following the cmip convention 
set nconcurrent  = 6        # number of concurrent processes to run, more = faster



set SrcDir = `pwd`


alias printusage 'echo "`basename $0` --caseid[-c] --centuries[-T] --year_range[-y] --caseidpath[-i] --outputpath[-o] \n --experiment[-e] --model[-m] --numcc [--cmip] [--ilamb] [--addfxflds]"'

if ($#argv == 0) then
   echo "`basename $0` --caseid[-c] --centuries[-T] --year_range[-y] --caseidpath[-i] --outputpath[-o] \
                       --experiment[-e] --model[-m] --numcc [--cmip] [--ilamb] [--addfxflds]"
   exit 1
endif


# command line arguments:


set longargs = ilamb,cmip,addfxflds,caseid:,centuries:,year_range:,caseidpath:,outputpath:,experiment:,model:,numcc: 
set shrtargs = c:T:y:i:o:e:m:
set CmdLine=(`getopt -s tcsh  -o  $shrtargs --long $longargs -- $argv:q`)

if ($? != 0) then 
  echo "Terminating..." >/dev/stderr
  exit 1
endif

eval set argv=\($CmdLine:q\)

while (1)
	switch($1:q)
	case -c:
        case --caseid:
                set caseid = $2
		echo "The case name: "\`$2:q\' ; shift ; shift
		breaksw
	case -T:
        case --centuries:
                set centuries = `echo $2:q | sed 's/,/ /g'`
		echo "The case simulated centuries: "\`$2:q\' ; shift ; shift
		breaksw
	case -y:
        case --year_range:
                set year_range = $2
		echo "The simulated year range: "\`$2:q\' ; shift ; shift
		breaksw
	case -i:
        case --caseidpath:
                set caseidpath = `readlink -f $2`
		echo "The directory of the case results: "\`$2:q\' ; shift ; shift
		breaksw
	case -o:
        case --outputpath:
                set outputpath = `readlink -f $2`
		echo "The output directory: "\`$2:q\' ; shift ; shift
		breaksw

        case -e:
        case --experiment:
                set experiment = $2
		echo "The experiment name: "\`$2:q\' ; shift ; shift
		breaksw

        case -m:
        case --model:
                set model = $2
		echo "The model name: "\`$2:q\' ; shift ; shift
		breaksw

        case --numcc:
                set nconcurrent = $2
		echo "Number of concurrent processes: "\`$2:q\' ; shift ; shift
		breaksw

        case --ilamb:
                set ilamb_fields = 1
                shift
                breaksw 

        case --cmip:
                set convert_to_cmip = 1
                shift
                breaksw 

        case --addfxflds:
                set add_fixed_flds = 1
                shift
                breaksw 

	case --:
		shift
		break
	default:
		echo "Internal error!" ; exit 1

        endsw
end

# foreach el ($argv:q) created problems for some tcsh-versions (at least
# 6.02). So we use another shift-loop here:
while ($#argv > 0)
        echo "Remaining arguments:"
	echo '--> '\`$1:q\'
	shift
        exit 1
end


if ( ! -f "clm_to_mip" && $convert_to_cmip == 1) then
   echo "clm_to_mip is needed for converting model outputs following cmip conventions" 
endif

if ( ! -d $outputpath ) then
   mkdir -p $outputpath
endif

if ( ! -d $outputpath/$caseid ) then
   mkdir $outputpath/$caseid
endif

cd $outputpath/$caseid

if ($ilamb_fields == 1) then 
  set fldlist_monthly = (ALT AR BTRAN CH4PROD DENIT EFLX_LH_TOT ELAI ER ESAI FAREA_BURNED \
    FCEV FCH4 FCH4TOCO2 FCOV FCTR FGEV FGR FGR12 FH2OSFC FINUNDATED FIRA FIRE FLDS FPG FPI \
    FPSN FROST_TABLE FSA FSAT FSDS FSH FSM FSNO FSR F_DENIT F_NIT GPP \
    GROSS_NMIN H2OSFC H2OSNO HR HTOP LAND_USE_FLUX LEAFC WOODC FROOTC NDEP_TO_SMINN NBP NEE NEP \
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

  set fldlist_annual = (ALTMAX PCO2 PCH4 SOIL1C_vr SOIL2C_vr SOIL3C_vr)

else
  set fldlist_monthly = (ALT FCH4 FAREA_BURNED EFLX_LH_TOT FH2OSFC LAND_USE_FLUX H2OSOI NBP NEE \
    NPP Q2M RAIN SNOW SNOWDP SNOW_DEPTH TWS VOLR ZWT TSA RH2M ORUNOFF QOVER QDRAI FSNO TSOI \
    TLAI TSAI ELAI ESAI FSH FSDS FSA FIRE FIRA LEAFC TOTSOMC TOTSOMC_1m TOTVEGC TOTECOSYSC \
    TLAKE CWDC COL_FIRE_CLOSS)

  set fldlist_monthly = (WOOD_HARVESTC)
  set fldlist_annual = ( )
endif




#mxu
# extract and concatenate monthly and annual fields for each century
#
foreach cent ($centuries)

   #mxu add the fixed fields output 
   echo $cent
   if ($add_fixed_flds == 1) then
      foreach fil ($caseidpath/$caseid.clm2.h0.${cent}??-*)
          echo $fil

          set funits = `ncks -C -u -v area $fil |grep -i units|grep -o '".*"'|sed 's/"//g'` 

          if ($funits == "km^2") then
              ncap2 -O -h -4 -v -s 'areacella=udunits(area,"m2");' $fil areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          else if ($funits == "steradian")
              ncap2 -O -h -4 -v -s 'areacella=area*6371000.*6371000.;' $fil areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"  
          endif

          ncatted -h -a units,areacella,o,c,'m2' areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          #-ncks -h -4 -cv area $fil areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          #-ncrename -h -v area,areacella areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"

          ncatted -h -a standard_name,areacella,o,c,'cell_area' areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a long_name,areacella,o,c,'Land grid-cell area' areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a comment,areacella,o,c,'from land model output, so it is masked out ocean part' areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a original_name,areacella,o,c,'area' areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a _FillValue,areacella,o,f,1.e20 areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a missing_value,areacella,o,f,1.e20 areacella"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
      
          ncap2 -O -h -4 -v -s 'sftlf=landfrac*100;' $fil sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc" 
          #-ncks -h -4 -cv landfrac $fil sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          #-ncrename -h -v landfrac,sftlf sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a standard_name,sftlf,o,c,'Land Area Fraction' sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a _FillValue,sftlf,o,f,1.e20 sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a missing_value,sftlf,o,f,1.e20 sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          ncatted -h -a units,sftlf,o,c,'%' sftlf"_fx_"${model}"_"${experiment}"_r0i0p0.nc"
          
          break
      end
      
      echo 'finished generating the fixed fields, areacella and sftlf'
      exit
   endif

   @ i = 0
   foreach fld ($fldlist_monthly)
       echo $fld
       @ i = $i + 1
       if ( $i % $nconcurrent == 0 ) then
           if ( $cent == "19" ) then
   	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.${cent}[89]?-* $caseid.$fld.monthly.$cent.nc
           else
   	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.${cent}??-* $caseid.$fld.monthly.$cent.nc
           endif
       else
           if ( $cent == "19" ) then
	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.${cent}[89]?-* $caseid.$fld.monthly.$cent.nc &
           else
	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.$cent??-* $caseid.$fld.monthly.$cent.nc &
           endif
       endif
   end
   wait

   foreach fld ($fldlist_annual)
       echo $fld
       @ i = $i + 1
       if ( $i % $nconcurrent == 0 ) then
           if ( $cent == "19" ) then
	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.${cent}[89]?-12.nc $caseid.$fld.annual.$cent.nc
           else
	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.$cent??-12.nc $caseid.$fld.annual.$cent.nc
           endif
       else
           if ( $cent == "19" ) then
	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.${cent}[89]?-12.nc $caseid.$fld.annual.$cent.nc &
           else
	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.$cent??-12.nc $caseid.$fld.annual.$cent.nc &
           endif
       endif
   end
   wait

# Compress files to netcdf4 format if requested
   @ i = 0
   if ($compress == 1) then
      foreach fld ($fldlist_monthly)
         echo compress $fld
         @ i = $i + 1
         if ( $i % $nconcurrent == 0 ) then
            ncks -4 -L 1 $caseid.$fld.monthly.$cent.nc $caseid.$fld.monthly.$cent.compress.nc
         else 
            ncks -4 -L 1 $caseid.$fld.monthly.$cent.nc $caseid.$fld.monthly.$cent.compress.nc &
         endif
      end

      wait

      foreach fld ($fldlist_annual)
         echo compress $fld
         @ i = $i + 1
         if ( $i % $nconcurrent == 0 ) then
            ncks -4 -L 1 $caseid.$fld.annual.$cent.nc $caseid.$fld.annual.$cent.compress.nc 
         else
            ncks -4 -L 1 $caseid.$fld.annual.$cent.nc $caseid.$fld.annual.$cent.compress.nc &
         endif
      end

      wait

      foreach fld ($fldlist_monthly)
         /bin/mv $caseid.$fld.monthly.$cent.compress.nc $caseid.$fld.monthly.$cent.nc
      end

      foreach fld ($fldlist_annual)
         /bin/mv $caseid.$fld.annual.$cent.compress.nc $caseid.$fld.annual.$cent.nc
      end

   endif

end

# concantenate compressed century length files into one spanning full year range
@ i = 0
foreach fld ($fldlist_monthly)
   echo $fld cat centuries
   @ i = $i + 1
   if ( $i % $nconcurrent == 0 ) then
      ncrcat -O $caseid.$fld.monthly.*.nc $caseid.$fld.monthly.$year_range.nc
   else 
      ncrcat -O $caseid.$fld.monthly.*.nc $caseid.$fld.monthly.$year_range.nc &
   endif
   wait
end

wait

@ i = 0
foreach fld ($fldlist_annual)
   echo $fld cat centuries
   @ i = $i + 1
   if ( $i % $nconcurrent == 0 ) then
      ncrcat -O $caseid.$fld.annual.*.nc $caseid.$fld.annual.$year_range.nc
   else
      ncrcat -O $caseid.$fld.annual.*.nc $caseid.$fld.annual.$year_range.nc &
   endif
end

wait

# remove century interim files
foreach fld ($fldlist_monthly)
   rm -f $caseid.$fld.monthly.??.nc
end
foreach fld ($fldlist_annual)
   rm -f $caseid.$fld.annual.??.nc
end

# convert to CMIP format
if ($convert_to_cmip == 1) then
   #cp /glade/u/home/dlawren/bin/clm_to_mip .

   #mxu add
   #/bin/cp -f /lustre/atlas1/cli106/proj-shared/mxu/ILAMB/clm_to_mip $outputpath/$caseid/
   #/bin/cp -f /lustre/atlas1/cli106/proj-shared/mxu/ALM_ILAMB/alm2lamb_wkflow/clm_to_mip $outputpath/$caseid/
   /bin/cp -f $SrcDir/clm_to_mip $outputpath/$caseid/
   cd $outputpath/$caseid/
   echo ./clm_to_mip ${model} ${experiment} ${year_range}
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
