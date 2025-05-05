#!/bin/bash

echo
echo "Bash script started"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
date

START_TIME=$SECONDS

g++ --version
gcc --version
cc --version

ATQA_DIR=AnalysisTreeQA
SOFT_DIR=/lustre/alice/users/lubynets/soft/$ATQA_DIR/install
source $SOFT_DIR/bin/AnalysisTreeQAConfig.sh

echo
echo "Environment variables are set"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=1

PROJECT_DIR=/lustre/alice/users/lubynets/QA

EXE_DIR=$SOFT_DIR/bin

# EXE=mc_qa
# EXE=treeKF_qa
EXE=mass_qa
# EXE=varCorr_qa
# EXE=bdt_qa

IO_SUFFIX=data/lhc22.apass7/all/noConstr/noSel/all MC_OR_DATA=data # 976
# IO_SUFFIX=mc/lhc24e3/sig_bgsup100/noConstr MC_OR_DATA=mc #403

INPUT_DIR=/lustre/alice/users/lubynets/bdt/outputs_atree/$IO_SUFFIX
OUTPUT_DIR=$PROJECT_DIR/outputs/$EXE/$IO_SUFFIX
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

if [ -f "filelist.list" ]; then
  rm filelist.list
fi

for K in `seq 1 $FILES_PER_JOB`; do
  FILE_NUMBER=$(($(($FILES_PER_JOB*$(($INDEX-1))))+$K))
  ls -d $INPUT_DIR/AnalysisTree.$FILE_NUMBER.root >> filelist.list
done

# ./$EXE filelist.list >& log_$INDEX.txt # mc_qa treeKF_qa
./$EXE filelist.list $MC_OR_DATA >& log_$INDEX.txt # varCorr_qa bdt_qa mass_qa

echo
echo "Exe done"
date

rm $EXE filelist.list
mv $EXE.root $EXE.$INDEX.root

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

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
