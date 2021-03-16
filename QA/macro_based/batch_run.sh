#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install-cpp11/bin/thisroot.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree/install-cpp11/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree/install-cpp11/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
SETUP_REC=mcpid/optimcuts

MACRO_DIR=$PROJECT_DIR/macro
MACRO=simmap_pt_y_phi

INPUT_DIR=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM
OUTPUT_DIR=${PROJECT_DIR}/outputs/$MACRO/$SETUP_SIM
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

# root -l -b -q "${MACRO}.C(\"$INPUT_DIR/$INDEX/fillerOut.$INDEX.root\")" >& log_${INDEX}.txt
root -l -b -q "${MACRO}.C(\"$INPUT_DIR/$INDEX/$INDEX.analysistree.root\")" >& log_${INDEX}.txt
                    
rm ${MACRO}.C

cd ..
mv $INDEX $OUTPUT_DIR

echo
echo "Bash script finished successfully"
date