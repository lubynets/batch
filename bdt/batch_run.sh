#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/bdt

WORK_DIR=$PROJECT_DIR/workdir
OUTPUT_DIR=$PROJECT_DIR/outputs/currentTry
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

export CONFIG_DIR=$PROJECT_DIR/config
export MACRO_DIR=$PROJECT_DIR/macro

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR/$INDEX/model
mkdir -p $OUTPUT_DIR/$INDEX/out
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

apptainer shell /lustre/alice/users/lubynets/singularities/bdt.sif << \EOF
source /usr/local/install/bin/thisroot.sh

python3 $MACRO_DIR/train_multi_class_BDT.py --config-file $CONFIG_DIR/config.train.$INDEX.yaml --config-file-sel $CONFIG_DIR/config.train_selection.yaml >& log_$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

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
