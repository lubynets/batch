#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/centrality/install_dev

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree_2/install_root6.20_cpp17_debian10/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/Centrality
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree_2/install_root6.20_cpp17_debian10/include/AnalysisTree

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/centradd

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm

EXE_DIR=$SOFT_DIR/bin
EXE=fill_centrality

FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/cbm2atree/$SETUP_SIM/1perfile
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP_SIM
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

CENTR_FILE=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/sts_centrality.root

./$EXE $FILELIST_DIR/filelist.$INDEX.list $CENTR_FILE >& log_$INDEX.txt

rm $EXE

cd ..
mv $INDEX $OUTPUT_DIR

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date