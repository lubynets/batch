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

PROJECT_DIR=/lustre/alice/users/lubynets/plainer

EXE_DIR=$SOFT_DIR/bin

IO_SUFFIX=mc/lhc24e3/all/noConstr/moreMoreVars # 403
# IO_SUFFIX=data/lhc22.apass7/all/noConstr/moreMoreVars #976

INPUT_DIR=/lustre/alice/users/lubynets/ali2atree/outputs/$IO_SUFFIX

EXE=plainer

OUTPUT_DIR=$PROJECT_DIR/outputs/${IO_SUFFIX}/
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

./$EXE $INPUT_DIR/AnalysisTree.$INDEX.root >& log_${INDEX}.txt

rm $EXE

mv PlainTree.root PlainTree.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR/jobs
if [ ! -f $LOG_DIR/jobs/$EXE.cpp ]; then
cp $SOFT_DIR/share/$EXE.cpp $LOG_DIR/jobs
fi
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
