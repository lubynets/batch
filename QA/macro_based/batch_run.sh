#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh
ANALYSISTREE_DIR=AnalysisTree_2

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/install_root6.20_cpp17_debian10/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/install_root6.20_cpp17_debian10/include/AnalysisTree

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56/TGeant4
# SETUP_REC=mcpid/defaultcuts/AT2/xi

MACRO_DIR=$PROJECT_DIR/macro
MACRO=multiplicity_qa

# INPUT_DIR=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC
# OUTPUT_DIR=${PROJECT_DIR}/outputs/$MACRO/$SETUP_SIM/$SETUP_REC
FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/cbm2atree/$SETUP_SIM
OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

# root -l -b -q "${MACRO}.C(\"$INPUT_DIR/$INDEX/$INDEX.analysistree.root\")" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}.C(\"$INPUT_DIR/$INDEX/PFSimpleOutput.$INDEX.root\")" >& log_${INDEX}.txt

root -l "${MACRO}.C({\"$FILELIST_DIR/filelist.$INDEX.list\"})" >& log_${INDEX}.txt
                    
rm ${MACRO}.C

cd ..
mv $INDEX $OUTPUT_DIR

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date