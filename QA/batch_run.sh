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

FITTER=KF
# FITTER=DF

SELECTION=noSel; SELECTION_FLAG=0
# SELECTION=isSel; SELECTION_FLAG=1

INPUT_DIR=/lustre/alice/users/lubynets/cresellc/outputs/$FITTER

MACRO=mass_qa

OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$FITTER/$SELECTION
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

root -l -b -q "${MACRO}.C(\"$INPUT_DIR/AnalysisResults_trees.$INDEX.root\", $SELECTION_FLAG)" >& log_${INDEX}.txt # mass_qa

rm $MACRO.C

mv $MACRO.root $MACRO.$INDEX.root

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

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
