#!/bin/bash

echo
echo "Bash script started"
date

source $USER/soft/root-6/install-cpp11/bin/thisroot.sh

SOFT_DIR=$USER/soft/PFSimple/install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$USER/soft/AnalysisTree/install-cpp11/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/external/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$USER/soft/AnalysisTree/install-cpp11/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=$USER/pfsimple

SETUP=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm

EXE_DIR=$SOFT_DIR/bin
# OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP/nopid/lightcuts1
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

echo
echo "Bash script finished successfully"
date