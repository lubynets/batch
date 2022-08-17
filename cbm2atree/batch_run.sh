#!/bin/bash

echo
echo "Bash script started"
date

CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install_apr20_at2_debian10
# CBMROOT=/u/lubynets/soft/cbmrootmaster/build/install

source $CBMROOT/bin/CbmRootConfig.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CBMROOT/lib/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

EVENT_GEN=dcmqgsm_smm
# EVENT_GEN=urqmd

# --------------------- 12 AGeV ---------------------------------------------------------------------------------------------------------
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto_w/auau/12agev/mbias/sis100_electron_target_25_mkm #          1-1000
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto_wdalitz/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001-2000
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto_etap/auau/12agev/mbias/sis100_electron_target_25_mkm #    2001-3000
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto_phi/auau/12agev/mbias/sis100_electron_target_25_mkm #     3001-4000
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto_rho0/auau/12agev/mbias/sis100_electron_target_25_mkm #    4001-5000

# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto_wdalitz/auau/12agev/mbias/sis100_electron_target_25_mkm

SETUP_OUT=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm/AT_spec
#----------------------------------------------------------------------------------------------------------------------------------------

# # --------------------- 3.3 AGeV --------------------------------------------------------------------------------------------------------
# SETUP_IN=/lustre/cbm/users/isegal/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/TGeant4 # 1-250
# # SETUP_IN=/lustre/cbm/users/iselyuzh/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_wdalitz/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/TGeant4 # 501-750
# # SETUP_IN=/lustre/cbm/users/kashirin/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_phi/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/TGeant4 # 1501-1750
# # SETUP_IN=/lustre/cbm/users/klochkov/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_rho0/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/TGeant4 # 2001-2250
# # SETUP_IN=/lustre/cbm/users/iselyuzh/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_inmed_had_epem/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/TGeant4 # 2501-2750
# 
# # SETUP_IN=/lustre/cbm/users/isegal/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto_w/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/TGeant4 # 1-50
# 
# # SETUP_OUT=apr20_fr_18.2.1_fs_jun19p1/${EVENT_GEN}_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56
# #----------------------------------------------------------------------------------------------------------------------------------------

# SETUP_IN=/lustre/cbm/users/ogolosov/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_no_mvd/TGeant4
# SETUP_OUT=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_no_mvd


PROJECT_DIR=/lustre/cbm/users/lubynets/cbm2atree
MACRO_DIR=${PROJECT_DIR}/macro
MACRO=run_analysis_tree_maker_at2.C
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP_OUT
LOG_DIR=$OUTPUT_DIR/log
# OUTPUT_DIR=${PROJECT_DIR}/outputs/temp
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp ${MACRO_DIR}/${MACRO} ./

root -l -b -q "${MACRO}(\"/lustre/cbm/pwg/common/mc/cbmsim/${SETUP_IN}/\", \"${INDEX}\")" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}(\"${SETUP_IN}/\", \"${INDEX}\")" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}(\"/lustre/cbm/users/ogolosov/mc/cbmsim/apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_apr20_target_25_mkm/TGeant4/\", \"${INDEX}\")" >& log_${INDEX}.txt

rm FairRunInfo* L1_histo.root ${MACRO} core*
mv *root $OUTPUT_DIR
mv log* $LOG_DIR


cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date