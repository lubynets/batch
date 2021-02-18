#!/bin/bash

source /lustre/cbm/users/lubynets/soft/root-6/install-cpp11/bin/thisroot.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/PFSimple/install/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/PFSimple/install/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree/install-cpp11/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/PFSimple/install/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/PFSimple/install/external/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTree/install-cpp11/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/pfsimple

SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm

EXE_DIR=/lustre/cbm/users/lubynets/soft/PFSimple/install/bin
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP/nopid/defaultcuts
OUTPUT_DIR=${PROJECT_DIR}/outputs/test
WORK_DIR=$PROJECT_DIR/workdir
FILELIST_DIR=$PROJECT_DIR/filelists/$SETUP

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/main ./

./main $FILELIST_DIR/filelist.$INDEX.list >& log_${INDEX}.txt

rm main
mv PFSimpleOutput.root PFSimpleOutput.$INDEX.root

cd ..
mv $INDEX $OUTPUT_DIR