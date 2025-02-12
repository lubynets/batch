#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

gcc --version
cc --version

source /lustre/alice/users/lubynets/soft/AnalysisTree/install_master/bin/AnalysisTreeConfig.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/ali2atree

EXE_DIR=/lustre/alice/users/lubynets/soft/AnalysisTree/install_master/bin

# IO_SUFFIX=data/lhc22.apass7_tm/noSel IS_MC=false # 976
IO_SUFFIX=mc/lhc24e3_tm/all/pidTuned IS_MC=true # 403
# IO_SUFFIX=signalOnly/relax # 403

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

cp $EXE_DIR/$EXE ./

./$EXE $INPUT_DIR/AnalysisResults_trees.$INDEX.root $IS_MC >& log_${INDEX}.txt

rm $EXE

mv AnalysisTree.root AnalysisTree.$INDEX.root

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
