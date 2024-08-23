#!/bin/bash

echo
echo "Bash script started"
date

GROUP=cbm
# GROUP=alice

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/$GROUP/users/lubynets/test_job

OUTPUT_DIR=$PROJECT_DIR/outputs
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

MACRO_DIR=$PROJECT_DIR/macro
MACRO=test_macro.C

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

root -l -b -q "${MACRO_DIR}/${MACRO}($INDEX)" >& log_${INDEX}.txt

mv *root $OUTPUT_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX

echo
echo "Bash script finished successfully"
date
