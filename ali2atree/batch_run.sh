#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

gcc --version
cc --version

SOFT_DIR=/lustre/alice/users/lubynets/soft/AnalysisTree/install_master_vae25

source $SOFT_DIR/bin/AnalysisTreeConfig.sh

INDEX=${SLURM_ARRAY_TASK_ID}

N_FILES_TO_BE_PLAINED=0

if [[ $INDEX -lt $(($N_FILES_TO_BE_PLAINED+1)) ]]; then
IS_DO_PLAIN=true
else
IS_DO_PLAIN=false
fi

IS_HAS_EVENT_INFO=false

# IO_SUFFIX=mc/lhc24e3/all/noConstr/moreMoreVars IS_MC=true # 403
# IO_SUFFIX=data/lhc22.apass7/all/noConstr/moreMoreVars IS_MC=false #976

IO_SUFFIX=HL/mc/HF_LHC24h1b_All/559554 IS_MC=true

INPUT_DIR=/lustre/alice/users/lubynets/CSTlc/outputs/$IO_SUFFIX

EXE=alicetree2at

OUTPUT_DIR=$PROJECT_DIR/outputs/${IO_SUFFIX}
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

# $EXE $INPUT_DIR/AnalysisResults_trees.$INDEX.root $IS_MC $IS_HAS_EVENT_INFO $IS_DO_PLAIN >& log_${INDEX}.txt # not unmerged Hyperloop
$EXE $INPUT_DIR/localAO2DList.txt:$INDEX $IS_MC $IS_HAS_EVENT_INFO $IS_DO_PLAIN >& log_${INDEX}.txt

mv AnalysisTree.root AnalysisTree.$INDEX.root
mv PlainTree.root PlainTree.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR/jobs
CP $SOFT_DIR/share $EXE.cpp $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

if [ ! -f $WORK_DIR/env.txt ]; then
echo "$LOG_DIR" > $WORK_DIR/env.txt
fi

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
