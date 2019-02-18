#!/usr/bin/env bash

#set -x

DATA=/global/cscratch1/sd/minxu/tmp/test_ncclimo
drc_in='/global/cscratch1/sd/minxu/archive/F_acmev03_enso_ne30_knl_cesmmach_co2cyc_pmpet_25yr_climpac/lnd/hist/' # Input directory
drc_out="${DATA}/ne30/clm_test1" # Native grid output directory
drc_rgr="${DATA}/ne30/rgr" # Regridded output directory
drc_tmp='/global/cscratch1/sd/minxu/tmp/tmp' # Temporary/intermediate-file directory
cmip6_opt='-7 --dfl_lvl=1 --no_cll_msr --no_frm_trm --no_stg_grd' # CMIP6-specific options
spl_opt='--yr_srt=1 --yr_end=27 --ypf=27' # 2D+3D Splitter options

#vars='FSDS,TBOT,SOILWATER_10CM,QOVER,QRUNOFF,QINTR,QVEGE,QSOIL,QVEGT,LAISUN,LAISHA,SOILICE,SOILLIQ,TSOI' # 2D+3D

ilambvars='ALT,AR,BTRAN,CH4PROD,DENIT,EFLX_LH_TOT,ELAI,ER,ESAI,FAREA_BURNED,
FCEV,FCH4,FCH4TOCO2,FCOV,FCTR,FGEV,FGR,FGR12,FH2OSFC,FINUNDATED,FIRA,FIRE,FLDS,FPG,FPI,
FPSN,FROST_TABLE,FSA,FSAT,FSDS,FSH,FSM,FSNO,FSR,F_DENIT,F_NIT,GPP,
GROSS_NMIN,H2OSFC,H2OSNO,HR,HTOP,LAND_USE_FLUX,LEAFC,FROOTC,NDEP_TO_SMINN,NBP,NEE,NEP,
NET_NMIN,NFIX_TO_SMINN,NPP,Q2M,QCHARGE,QDRAI,QOVER,QRUNOFF,QRGWL,QSNOMELT,
QSOIL,QVEGE,QVEGT,RAIN,RH2M,SMIN_NO3,SMIN_NH4,SNOW,SNOWDP,SNOWICE,SNOWLIQ,SNOW_DEPTH,
SNOW_SINKS,SNOW_SOURCES,SOMHR,TG,TSA,TSAI,TLAI,TV,QBOT,TBOT,
AGNPP,FROOTC_ALLOC,LEAFC_ALLOC,WOODC_ALLOC,WOOD_HARVESTC,
CH4_SURF_AERE_SAT,CH4_SURF_AERE_UNSAT,CH4_SURF_DIFF_SAT,
CH4_SURF_DIFF_UNSAT,CH4_SURF_EBUL_SAT,CONC_CH4_SAT,
CONC_CH4_UNSAT,FCH4_DFSAT,MR,TOTCOLCH4,ZWT_CH4_UNSAT,
FSDSND,FSDSNI,FSDSVD,FSDSVI,
TWS,VOLR,WA,ZWT_PERCH,ZWT,WIND,COL_FIRE_CLOSS,
F_DENIT_vr,F_NIT_vr,H2OSOI,O_SCALAR,SOILICE,SOILLIQ,SOILPSI,TLAKE,TSOI,T_SCALAR,W_SCALAR,
SOIL1N,SOIL2N,SOIL3N,SOIL1C,SOIL2C,SOIL3C,TOTVEGC,TOTVEGN,TOTECOSYSC,TOTLITC,TOTLITC_1m,TOTLITN_1m,TOTSOMC,TOTSOMC_1m,TOTSOMN_1m,CWDC,PBOT'

vars="$(echo -e "${ilambvars}" | tr -d '[:space:]')"

echo $vars

exit 2

export TMPDIR=${drc_tmp}
#/bin/rm ~/ncremap.lnd
# Create SGS map from first file, then split all files, then regrid all split files
# Applying SGS map on its own, outside of SGS mode, does not append correct area, sgs_frc, sgs_msk to output
# This is acceptable for single variable output timeseries (like CMIP6) that lack area, sgs_frc, sgs_msk
#-ncremap -a aave -P sgs -s ${DATA}/grids/ne30np4_pentagons.091226.nc -g ${DATA}/grids/cmip6_180x360_scrip.20181001.nc -m ${DATA}/maps/map_ne30np4_to_cmip6_180x360_sgs_elm.20190301.nc --drc_out=${drc_rgr} ${drc_in}/20180129.DECKv1b_piControl.ne30_oEC.edison.clm2.h0.0001-01.nc > ~/ncremap.lnd 2>&1
# Native Land

which ncclimo
export TMPDIR=${drc_tmp}
cd ${drc_in}
time /bin/ls *.clm2.h0.25[78][0-9]-*.nc *.clm2.h0.259[0-6]-*.nc | /global/homes/z/zender/bin_edison/ncclimo -c mycase --var=${vars} --job_nbr=136 ${cmip6_opt} ${spl_opt} --drc_out=${drc_out} >> ~/ncclimo.lnd 2>&1
# Regrid Land
#-export TMPDIR=${drc_tmp};cd ${drc_out};/bin/ls *_000101_001012.nc | ncremap -a aave ${cmip6_opt} -m ${DATA}/maps/map_ne30np4_to_cmip6_180x360_sgs_elm.20190301.nc --drc_out=${drc_rgr} >> ~/ncremap.lnd 2>&1
