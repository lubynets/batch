#!/bin/bash

source /lustre/cbm/users/lubynets/soft/root-6/install-cpp11/bin/thisroot.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree/install-cpp11/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/external/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/external/include/pid
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/external/include/centrality
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree/install-cpp11/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/atfiller

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
SETUP_REC=nopid/defaultcuts

EXE_DIR=/lustre/cbm/users/lubynets/soft/analysis_tree_filler/install/bin
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP_SIM/$SETUP_REC
WORK_DIR=$PROJECT_DIR/workdir
CENTRALITY_FILE=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/sts_centrality.root
FILELIST_PRIM_DIR=/lustre/cbm/users/lubynets/pfsimple/filelists/$SETUP_SIM

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/filler ./

ls -d /lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC/$INDEX/PFSimpleOutput.$INDEX.root > filelist_sec.txt

./filler $FILELIST_PRIM_DIR/filelist.$INDEX.txt filelist_sec.txt fillerOut.$INDEX.root $CENTRALITY_FILE >& log_${INDEX}.txt

rm filler filelist_sec.txt

cd ..
mv $INDEX $OUTPUT_DIR
