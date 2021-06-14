#!/bin/bash

# CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install
CBMROOT=/u/lubynets/soft/cbmrootmaster/build/install

source $CBMROOT/bin/CbmRootConfig.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CBMROOT/lib/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

# SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_target_25_mkm #          1-1000
# SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_wdalitz/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001-2000
# SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_etap/auau/12agev/mbias/sis100_electron_target_25_mkm #    2001-3000
# SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_phi/auau/12agev/mbias/sis100_electron_target_25_mkm #     3001-4000
# SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_rho0/auau/12agev/mbias/sis100_electron_target_25_mkm #    4001-5000
# SETUP=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto_wdalitz/auau/12agev/mbias/sis100_electron_target_25_mkm

PROJECT_DIR=/lustre/cbm/users/lubynets/cbm2atree
MACRO_DIR=${PROJECT_DIR}/macro
MACRO=run_analysis_tree_maker_at2.C
OUTPUT_DIR=${PROJECT_DIR}/outputs/apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_apr20_target_25_mkm/TGeant4
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp ${MACRO_DIR}/${MACRO} ./

# root -l -b -q "${MACRO}(\"/lustre/cbm/pwg/common/mc/cbmsim/${SETUP}/\", \"${INDEX}\")" >& log_${INDEX}.txt
root -l -b -q "${MACRO}(\"/lustre/cbm/users/ogolosov/mc/cbmsim/apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_apr20_target_25_mkm/TGeant4/\", \"${INDEX}\")" >& log_${INDEX}.txt

rm FairRunInfo* L1_histo.root ${MACRO}

cd ..
mv $INDEX $OUTPUT_DIR