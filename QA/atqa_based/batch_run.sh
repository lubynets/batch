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
SOFT_DIR=/lustre/alice/users/lubynets/soft/$ATQA_DIR/install_vae25
source $SOFT_DIR/bin/AnalysisTreeQAConfig.sh

echo
echo "Environment variables are set"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=1

PROJECT_DIR=/lustre/alice/users/lubynets/QA

# EXE=mc_qa
# EXE=treeKF_qa
EXE=mass_qa
# EXE=varCorr_qa
# EXE=bdt_qa
# EXE=yield_lifetime_qa

# MODEL_NAME=moreMoreVars
# IO_SUFFIX=data/lhc22.apass7/all/noConstr/$MODEL_NAME MC_OR_DATA=data # 976
# IO_SUFFIX=mc/lhc24e3/all/noConstr/$MODEL_NAME MC_OR_DATA=mc #403

IO_SUFFIX=HL/data/HF_LHC22o_pass7_minBias_2P3PDstar/474011 MC_OR_DATA=data

WEIGHTS_FILE=/lustre/alice/users/lubynets/QA/input/ptWeight.root

# INPUT_DIR=/lustre/alice/users/lubynets/bdt/outputs_atree/$IO_SUFFIX
INPUT_DIR=/lustre/alice/users/lubynets/ali2atree/outputs/$IO_SUFFIX
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

RM filelist.list

for K in `seq 1 $FILES_PER_JOB`; do
  FILE_NUMBER=$(($(($FILES_PER_JOB*$(($INDEX-1))))+$K))
  ls -d $INPUT_DIR/AnalysisTree.$FILE_NUMBER.root >> filelist.list
done

if [[ $EXE == "treeKF_qa" ]]; then
ARGS="filelist.list"  # mc_qa treeKF_qa
elif [[ $EXE == "varCorr_qa" || $EXE == "bdt_qa" || $EXE == "mass_qa" ]]; then
ARGS="filelist.list $MC_OR_DATA" # varCorr_qa bdt_qa mass_qa
elif [[ $EXE == "yield_lifetime_qa" ]]; then
ARGS="filelist.list $WEIGHTS_FILE" # yield_lifetime_qa
fi

$EXE $ARGS >& log_$INDEX.txt

echo
echo "Exe done"
date

rm filelist.list
mv $EXE.root $EXE.$INDEX.root

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
