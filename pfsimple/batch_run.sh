#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/$USER/soft/root-6/install-cpp11/bin/thisroot.sh

PFSIMPLE_DIR=PFSimple_NEW
ANALYSISTREE_DIR=AnalysisTree_2

SOFT_DIR=/lustre/cbm/users/$USER/soft/$PFSIMPLE_DIR/install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/$USER/soft/$ANALYSISTREE_DIR/install-cpp11/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/external/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/$USER/soft/$ANALYSISTREE_DIR/install-cpp11/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/$USER/pfsimple

SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP=apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_apr20_target_25_mkm/TGeant4
# SETUP=apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_apr20_target_25_mkm/TGeant4

EXE_DIR=$SOFT_DIR/bin
EXE=main2
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP/mcpid/nocuts/AT2/kaon
WORK_DIR=$PROJECT_DIR/workdir
FILELIST_DIR=$PROJECT_DIR/filelists/$SETUP

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

./$EXE $FILELIST_DIR/filelist.$INDEX.list >& log_${INDEX}.txt

rm $EXE
mv PFSimpleOutput.root PFSimpleOutput.$INDEX.root

cd ..
mv $INDEX $OUTPUT_DIR

echo
echo "Bash script finished successfully"
date