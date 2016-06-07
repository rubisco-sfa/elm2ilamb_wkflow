#!/bin/tcsh
module load udunits

# Permafrost RCN settings
set caseid       = clm45bgc_hrv_1DDD_1deg4508_rcp85_cIMPEDv2
set centuries    = (20 21 22)
set year_range   = 2006-2299
#set centuries    = (18 19 20)
#set year_range   = 1850-2005
set caseidpath     = /glade/scratch/dlawren/archive/$caseid/lnd/hist
set outputpath   = /glade/scratch/dlawren/permafrostRCN_modeldata

#CAM5-CLM4.5 settings
set caseid       = cam5clm45bgc_2degcesm13beta11_2000
set centuries    = (00)
set year_range   = 1-10 
set caseidpath     = /glade/scratch/dlawren/archive/$caseid/lnd/hist
set outputpath   = /glade/scratch/dlawren/CAM5-CLM4.5BGC

#ILAMB
set caseid       = clm40cn_1deg4502_hist
set centuries    = (18 19 20)
set year_range   = 185001-201012
set caseidpath     = /glade/scratch/dlawren/archive/$caseid/lnd/hist
set outputpath   = /glade/p/work/dlawren/ILAMB
set experiment   = historical
set model        = CLM45bgc_GSWP3

#GSWP3
#set caseid       = GSWP3_0.5d_IHISTCLM45
#set centuries    = (19 20)
#set year_range   = 1970-2010
#set caseidpath     = /glade/scratch/dlawren/archive/$caseid/lnd/hist
#set outputpath   = /glade/p/work/dlawren/ILAMB

#LUMIP
set caseid       = b.e11.B1850C5CN.f09_g16.10mil_reg_tdf
set centuries    = (18 19)
set year_range   = 1850-1920
set caseidpath   = /glade/scratch/dlawren/archive/$caseid/lnd/hist
set outputpath   = /glade/scratch/dlawren/LUMIP/CESM
set experiment   = 10mil_reg_tdf
set model        = CCSM4

set caseid       = b.e11.B1850C5CN.f09_g16.005
set centuries    = (10 11)
set year_range   = 1001-1131
set caseidpath   = /glade/scratch/dlawren/archive/$caseid/lnd/hist
set outputpath   = /glade/scratch/dlawren/LUMIP/CESM
set experiment   = picontrol
set model        = CCSM4

#ALMv1_CRUNCEP
set caseid       = GLOB_ILAMB_TITAN_TRANS
set centuries    = (19 20)
set year_range   = 1970-2010
set caseidpath    = /home/forrest/output_for_ilamb/monthly_h0_1970-2010
set outputpath   = /home/forrest/output_for_ilamb/ILAMB
set experiment   = historical
set model        = ALMv1_CRUNCEP

#ACME first ~5y water cycle experiment
set caseid       = interpfv09_20160308.A_WCYCL2000.ne30_oEC.edison.alpha3_01
set centuries    = (19 20)
set year_range   = 1970-2014
set caseidpath   = /lustre/atlas1/cli106/world-shared/mxu/20160308.A_WCYCL2000/fv09_masked_new/explode/
set outputpath   = /lustre/atlas1/cli106/world-shared/mxu/20160308.A_WCYCL2000/ILAMB/
set experiment   = historical
set model        = A_WCYCL2000


set caseid       = ALM_SPtest360x720_eos
set centuries    = (19 20)
set year_range   = 1980-2010
set caseidpath   = /lustre/atlas1/cli106/scratch/hof/monthly_h0_1850-2010_ilambvars_SP/
set outputpath   = /lustre/atlas1/cli106/proj-shared/mxu/ILAMB/MODELS/
set experiment   = historical
set model        = ALM_SP

set caseid       = interp_20160520.A_WCYCL1850.ne30_oEC.edison.alpha6_01
set centuries    = (19 20)
set year_range   = 1981-2010
set caseidpath   = /lustre/atlas1/cli106/proj-shared/mxu/ILAMB/ALM_WCYCL/explode/
set outputpath   = /lustre/atlas1/cli106/proj-shared/mxu/ILAMB/ALM_WCYCL/
set experiment   = historical
set model        = ALM_WCYCL



set compress     = 1
set convert_to_cmip = 1
set ilamb_fields = 0

mkdir $outputpath
mkdir $outputpath/$caseid

cd $outputpath/$caseid



if ($ilamb_fields == 0) then 
  set fldlist_monthly = (ALT AR BTRAN CH4PROD DENIT EFLX_LH_TOT ELAI ER ESAI FAREA_BURNED \
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

  set fldlist_annual = (ALTMAX PCO2 PCH4 SOIL1C_vr SOIL2C_vr SOIL3C_vr)

else
  set fldlist_monthly = (ALT FCH4 FAREA_BURNED EFLX_LH_TOT FH2OSFC LAND_USE_FLUX H2OSOI NBP NEE \
    NPP Q2M RAIN SNOW SNOWDP SNOW_DEPTH TWS VOLR ZWT TSA RH2M ORUNOFF QOVER QDRAI FSNO TSOI \
    TLAI TSAI ELAI ESAI FSH FSDS FSA FIRE FIRA LEAFC TOTSOMC TOTSOMC_1m TOTVEGC TOTECOSYSC \
    TLAKE CWDC COL_FIRE_CLOSS)

  set fldlist_monthly = (WOOD_HARVESTC)
  set fldlist_annual = ( )
endif

set nconcurrent  = 6   # number of concurrent processes to run, more = faster
#mxu

# extract and concatenate monthly and annual fields for each century
#
foreach cent ($centuries)

   @ i = 0
   foreach fld ($fldlist_monthly)
       echo $fld
       @ i = $i + 1
       if ( $i % $nconcurrent == 0 ) then
           if ( $cent == "19" ) then
   	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.${cent}[89]?-* $caseid.$fld.monthly.$cent.nc
           else
   	      ncrcat -O -cv $fld $caseidpath/$caseid.clm2.h0.$cent??-* $caseid.$fld.monthly.$cent.nc
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
   /bin/cp -f /lustre/atlas1/cli106/proj-shared/mxu/ILAMB/clm_to_mip $outputpath/$caseid/
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
