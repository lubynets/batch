#!/bin/bash

source /lustre/cbm/users/lubynets/soft/cbmroot/install/bin/CbmRootConfig.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/cbmroot/install/lib/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/cbmroot/install/include/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/cbmroot/install/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_rho0/auau/12agev/mbias/sis100_electron_target_25_mkm

PROJECT_DIR=/lustre/cbm/users/lubynets/cbm2atree
MACRO_DIR=${PROJECT_DIR}/macro
MACRO=run_analysis_tree_maker.C
OUTPUT_DIR=${PROJECT_DIR}/outputs/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp ${MACRO_DIR}/${MACRO} ./

root -l -b -q "${MACRO}(\"/lustre/cbm/pwg/common/mc/cbmsim/${SETUP}/\", \"${INDEX}\")" >& log_${INDEX}.txt

rm FairRunInfo* L1_histo.root ${MACRO}

cd ..
mv $INDEX $OUTPUT_DIR