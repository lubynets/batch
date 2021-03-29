#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17/bin/thisroot.sh
module use /cvmfs/it.gsi.de/modulefiles
module load compiler/gcc/9.1.0

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTreeQA/install/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTreeQA/install/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTreeQA/install/external/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/AnalysisTreeQA/install/include/AnalysisTreeQA

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
SETUP_REC=nopid/nocuts_fCM9

EXE_DIR=/lustre/cbm/users/lubynets/soft/AnalysisTreeQA/install/bin
EXE=pfs_qa

FILELIST_DIR=$PROJECT_DIR/filelists/$SETUP_SIM/$SETUP_REC
OUTPUT_DIR=${PROJECT_DIR}/outputs/$EXE/$SETUP_SIM/$SETUP_REC/nocuts/sgnl_12
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

./$EXE $FILELIST_DIR/filelist.$INDEX.list >& log_$INDEX.txt

rm $EXE

cd ..
mv $INDEX $OUTPUT_DIR

echo
echo "Bash script finished successfully"
date