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

g++ --version
gcc --version
cc --version

ATQA_DIR=AnalysisTreeQA
SOFT_DIR_AT=/lustre/alice/users/lubynets/soft/$ATQA_DIR/install_vae25
source $SOFT_DIR_AT/bin/AnalysisTreeQAConfig.sh
SOFT_DIR_QA2=/lustre/alice/users/lubynets/soft/qa2
source $SOFT_DIR_QA2/bin/qa2Config.sh

echo
echo "Environment variables are set"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=1

PROJECT_DIR_LUSTRE=/lustre/alice/users/lubynets/QA

if [[ "$WHERE_TO_RUN" == "lustre" ]]; then
  PROJECT_DIR_TMP=$PROJECT_DIR_LUSTRE
else
  PROJECT_DIR_TMP=/tmp/lubynets/QA
fi

# EXE=mc_qa
# EXE=treeKF_qa
# EXE=mass_qa
# EXE=varCorr_qa
# EXE=bdt_qa
# EXE=yield_lifetime_qa
EXE=mass_bdt_qa_thn
# EXE=yield_lifetime_qa_thn

IO_SUFFIX=HL/data/HF_LHC23_pass4_Thin_2P3PDstar/574294 MC_OR_DATA=data

WEIGHTS_FILE=/lustre/alice/users/lubynets/QA/input/ptWeight.root

INPUT_DIR=/lustre/alice/users/lubynets/CSTlc/outputs/$IO_SUFFIX
FILELIST=$INPUT_DIR/localAnalysisResultsList.txt
# OUTPUT_DIR=$PROJECT_DIR_LUSTRE/outputs/$EXE/$IO_SUFFIX/ctbin1/BGwise
OUTPUT_DIR=$PROJECT_DIR_LUSTRE/outputs/$EXE/draft
WORK_DIR_LUSTRE=$PROJECT_DIR_LUSTRE/workdir
WORK_DIR_TMP=$PROJECT_DIR_TMP/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR_TMP/log

RM $WORK_DIR_TMP/$INDEX
mkdir -p $WORK_DIR_TMP/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs

cd $WORK_DIR_TMP/$INDEX

RM filelist.list

if [[ $EXE == "treeKF_qa" || $EXE == "varCorr_qa" || $EXE == "bdt_qa" || $EXE == "mass_qa" || $EXE == "yield_lifetime_qa" ]]; then
  for K in `seq 1 $FILES_PER_JOB`; do
    FILE_NUMBER=$(($(($FILES_PER_JOB*$(($INDEX-1))))+$K))
    ls -d $INPUT_DIR/AnalysisTree.$FILE_NUMBER.root >> filelist.list
  done
fi

if [[ $EXE == "treeKF_qa" ]]; then
  ARGS="filelist.list"  # mc_qa treeKF_qa
elif [[ $EXE == "varCorr_qa" || $EXE == "bdt_qa" || $EXE == "mass_qa" ]]; then
  ARGS="filelist.list $MC_OR_DATA" # varCorr_qa bdt_qa mass_qa
elif [[ $EXE == "yield_lifetime_qa" ]]; then
  ARGS="filelist.list $WEIGHTS_FILE" # yield_lifetime_qa
elif [[ $EXE == "mass_bdt_qa_thn" ]]; then
  INPUT_FILE=$(ReadNthLine $FILELIST $INDEX)
  if [[ "$WHERE_TO_RUN" == "tmp_jobandinput" ]]; then
    cp $INPUT_FILE .
    INPUT_FILE=$(basename $INPUT_FILE)
  fi
  ARGS="$INPUT_FILE 0" # mass_bdt_qa_thn
elif [[ $EXE == "yield_lifetime_qa_thn" ]]; then
  ARGS="${FILELIST}:$INDEX $WEIGHTS_FILE" # yield_lifetime_qa_thn
fi

echo
echo "Exe start"
date
EXE_START_TIME=$SECONDS

$EXE $ARGS >& log_$INDEX.txt

echo
echo "Exe done"
date
EXE_FINISH_TIME=$SECONDS

RM filelist.list
mv $EXE.root $EXE.$INDEX.root

mv $EXE.$INDEX.root $OUTPUT_DIR
mv log* $LOG_DIR/jobs
CP $SOFT_DIR_AT/share $EXE.cpp $LOG_DIR
CP $SOFT_DIR_QA2/share $EXE.cpp $LOG_DIR

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR_LUSTRE/success
cd $WORK_DIR_LUSTRE/success
touch index_${INDEX}

echo "Before env.txt"
if [ ! -f $WORK_DIR_LUSTRE/env.txt ]; then
echo "Created env.txt in $WORK_DIR_LUSTRE"
echo "$LOG_DIR" > $WORK_DIR_LUSTRE/env.txt
fi
echo "After env.txt"

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "Exe run elapsed time " $(($(($EXE_FINISH_TIME-$EXE_START_TIME))/60)) "m " $(($(($EXE_FINISH_TIME-$EXE_START_TIME))%60)) "s"
echo "Bash script elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
