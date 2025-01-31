#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

gcc --version
cc --version

source /lustre/alice/users/lubynets/soft/root/install_6.32_cpp17/bin/thisroot.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/QA

MACRO_DIR=$PROJECT_DIR/macro

PRESELECTION=lhc24e3
# PRESELECTION=relax

SELECTION=noSel; SELECTION_FLAG=0
# SELECTION=isSel; SELECTION_FLAG=1

INPUT_DIR=/lustre/alice/users/lubynets/CSTlc/outputs/signalOnly/$PRESELECTION

# MACRO=mass_qa
# MACRO=treeKF_qa
MACRO=mc_qa

OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$PRESELECTION/$SELECTION
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

root -l -b -q "${MACRO}.C(\"$INPUT_DIR/AnalysisResults_trees.$INDEX.root\", $SELECTION_FLAG)" >& log_${INDEX}.txt # mass_qa, treeKF_qa, mc_qa

rm $MACRO.C

mv $MACRO.root $MACRO.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
