#!/bin/bash

CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install_apr20_at2_debian10

source $CBMROOT/bin/CbmRootConfig.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CBMROOT/lib/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

# INPUT_PATH=/lustre/cbm/pwg/common/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_target_25_mkm

PROJECT_DIR=/lustre/cbm/users/$USER/cbm2atree_temp
MACRO_DIR=${PROJECT_DIR}/macro
MACRO=run_analysis_tree_maker_at2.C
OUTPUT_DIR=${PROJECT_DIR}/outputs/temp
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp ${MACRO_DIR}/${MACRO} ./

# root -l -b -q "${MACRO}(\"${INPUT_PATH}/\", \"${INDEX}\")" >& log_${INDEX}.txt
root -l -b -q ${MACRO} >& log_${INDEX}.txt

rm FairRunInfo* L1_histo.root core* ${MACRO}

cd ..
mv $INDEX $OUTPUT_DIR