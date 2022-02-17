#!/usr/bin/env bash



#drwxr-s---  7 cmip6 cmip6  4096 Feb 28  2019 20180907_princeton_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Feb 28  2019 20180910_cruncepv8_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Apr 10  2019 20180910_princeton_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Feb 28  2019 20180912_gswp3v2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Apr 12  2019 20190224_princeton_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Apr 11  2019 20190319_gspwv2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Apr 17  2019 20190320_gswpv2_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC
#drwxr-s---  7 cmip6 cmip6  4096 Apr 24  2019 20190328_cruncepv8_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC
#

#casenames=("20180912_gswp3v2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC" \
#           "20190319_gspwv2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC" \
#           "20180910_cruncepv8_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC" \
#           "20180910_princeton_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC")
#

#-casenames=("20190320_gswpv2_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC" \
#-           "20190224_princeton_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC"\
#-           "20190328_cruncepv8_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC")

#-casenames=("20190224_princeton_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC"\
#-           "20190328_cruncepv8_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC")

#casenames=("20190224_princeton_cn_hcru_hcru_S6_hcru_hcru_ICB20TRCNRDCTCBC")  1850-2012
#casenames="20190319_gspwv2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC"


# CNP case
casenames=("20190319_gspwv2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC" \
           "20180910_cruncepv8_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC" \
           "20180910_princeton_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC")

#-casenames=("20190319_gspwv2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC")
mkdir -p ~/scratch/LS3MIP_CMOR_20210419

for case in "${casenames[@]}"; do
    echo $case
    #./elm_singlevar_ts.bash -c $case -y 1850-2014 -a 0 -i /global/cfs/projectdirs/m3522/cmip6/LS3MIP-E3SM/${case}/lnd/hist/ -o ~/scratch/LS3MIP_CMOR/ \
    #./elm_singlevar_ts.bash -c $case -y 1850-2014 -a 0 -i /global/cfs/projectdirs/m3522/cmip6/LS3MIP-E3SM/${case}/lnd/hist/ -o ~/scratch/LS3MIP_CMOR/ \
    # --ncclimo --linkfil --ilamb -e LS3MIP -m E3SM --prepcmor

    trange=1850-2014
    if [[ "$case" == *"princeton"* ]]; then
	    trange=1850-2012
    fi

    if [[ "$case" == *"cruncep"* ]]; then
	    trange=1850-2016
    fi
    ./elm_singlevar_ts.bash -c $case -y $trange -a 0 -i /global/cfs/projectdirs/m3522/cmip6/LS3MIP-E3SM/${case}/lnd/hist/ -o ~/scratch/LS3MIP_CMOR_20210419/ \
     --ncclimo --linkfil --ilamb -e LS3MIP -m E3SM 

   #./tool/gen_area_bound.sh /global/cfs/projectdirs/m3522/cmip6/LS3MIP-E3SM/${case}/lnd/hist/${case}.clm2.h0.1990-01.nc ~/scratch/LS3MIP_CMOR_20210419/${case}/org/lnd
done

#./elm_singlevar_ts.bash -c 20180912_gswp3v2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC -y 1850-2014 -a 0 -i /global/cfs/projectdirs/m3522/cmip6/LS3MIP-E3SM/20190319_gspwv2_hcru_hcru_S6_hcru_hcru_ICB20TRCNPRDCTCBC/lnd/hist/ -o ~/scratch/LS3MIP_CMOR/ --ncclimo --linkfil --ilamb -e LS3MIP -m E3SM
