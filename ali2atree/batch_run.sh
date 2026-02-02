#!/bin/bash

START_TIME=$SECONDS

WHERE_TO_RUN=${1}
if [[ "$WHERE_TO_RUN" != "lustre" && "$WHERE_TO_RUN" != "tmp_jobonly" && "$WHERE_TO_RUN" != "tmp_jobandinput" ]]; then
  echo "WHERE_TO_RUN = "$WHERE_TO_RUN ", while it must be lustre, tmp_jobonly or tmp_jobandinput"
  exit
fi

echo
echo "Bash script started"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
echo "HOSTNAME="$HOSTNAME
date

gcc --version
g++ --version
cc --version

SOFT_DIR=/lustre/alice/users/lubynets/soft/AnalysisTree/install_master_vae25
source $SOFT_DIR/bin/AnalysisTreeConfig.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR_LUSTRE=/lustre/alice/users/lubynets/ali2atree
if [[ "$WHERE_TO_RUN" == "lustre" ]]; then
  PROJECT_DIR_TMP=$PROJECT_DIR_LUSTRE
else
  PROJECT_DIR_TMP=/tmp/lubynets/ali2atree
fi

N_FILES_TO_BE_PLAINED=0
if [[ $INDEX -lt $(($N_FILES_TO_BE_PLAINED+1)) ]]; then
  IS_DO_PLAIN=true
else
  IS_DO_PLAIN=false
fi

IS_HAS_EVENT_INFO=false

IO_SUFFIX=HL/mc/HF_LHC24h1b_All/595984 IS_MC=true

INPUT_DIR=/lustre/alice/users/lubynets/CSTlc/outputs/$IO_SUFFIX

EXE=alicetree2at

OUTPUT_DIR=$PROJECT_DIR_LUSTRE/outputs/${IO_SUFFIX}
WORK_DIR_LUSTRE=$PROJECT_DIR_LUSTRE/workdir
WORK_DIR_TMP=$PROJECT_DIR_TMP/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

RM $WORK_DIR_TMP/$INDEX
mkdir -p $WORK_DIR_TMP/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs

cd $WORK_DIR_TMP/$INDEX

INPUT_FILE=$(ReadNthLine $INPUT_DIR/localAO2DList.txt $INDEX)
if [[ "$WHERE_TO_RUN" == "tmp_jobandinput" ]]; then
  cp $INPUT_FILE .
  INPUT_FILE=$(basename $INPUT_FILE)
fi

echo
echo "Exe start"
date
EXE_START_TIME=$SECONDS

$EXE $INPUT_FILE $IS_MC $IS_HAS_EVENT_INFO $IS_DO_PLAIN >& log_${INDEX}.txt

echo
echo "Exe done"
date
EXE_FINISH_TIME=$SECONDS

mv AnalysisTree.root $OUTPUT_DIR/AnalysisTree.$INDEX.root
mv PlainTree.root $OUTPUT_DIR/PlainTree.$INDEX.root

mv log* $LOG_DIR/jobs
CP $SOFT_DIR/share $EXE.cpp $LOG_DIR

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR_LUSTRE/success
cd $WORK_DIR_LUSTRE/success
touch index_${INDEX}

if [ ! -f $WORK_DIR_LUSTRE/env.txt ]; then
echo "$LOG_DIR" > $WORK_DIR_LUSTRE/env.txt
fi

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "Exe run elapsed time " $(($(($EXE_FINISH_TIME-$EXE_START_TIME))/60)) "m " $(($(($EXE_FINISH_TIME-$EXE_START_TIME))%60)) "s"
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
