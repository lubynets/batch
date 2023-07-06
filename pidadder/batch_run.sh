#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/Pid/install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/pid
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/pidadd

# EVEGEN=urqmd PBEAM=12    SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm
# EVEGEN=dcmqgsm PBEAM=12  SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm
EVEGEN=dcmqgsm PBEAM=3.3 SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56

EXE_DIR=$SOFT_DIR/bin
EXE=fill_pid

INPUT_DIR=/lustre/cbm/users/lubynets/centradd/outputs/$SETUP_SIM
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

PID_FILE=$PROJECT_DIR/getters/pid_getter.apr20.${EVEGEN}.${PBEAM}agev.root

ls -d $INPUT_DIR/centrality.analysistree.$INDEX.root > filelist.list

./$EXE filelist.list $PID_FILE >& log_$INDEX.txt

rm $EXE filelist.list

mv pid.analysistree.root pid.analysistree.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date
