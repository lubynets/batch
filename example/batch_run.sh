#!/bin/bash

echo
echo "Bash script started"
date
hostname

START_TIME=$SECONDS

gcc --version
cc --version

source /lustre/alice/users/lubynets/soft/root/install_6.32_cpp17_vae25/bin/thisroot.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/QA
# PROJECT_DIR=/tmp/lubynets/QA

OUTPUT_DIR=/lustre/alice/users/lubynets/QA/outputs/test
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

echo "Start creating directories"
mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error
echo "Directories created successfully"

cd $WORK_DIR/$INDEX

cp /lustre/alice/users/lubynets/QA/macro/fillGauss.C ./

root -l -b -q "fillGauss.C($INDEX)" >& log_${INDEX}.txt

rm fillGauss.C

mv fillGauss.root fillGauss.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error

cd ..
rm -r $INDEX

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
