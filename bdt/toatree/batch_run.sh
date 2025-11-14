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

EXE_DIR=$SOFT_DIR/bin

MODEL_NAME=moreMoreVars

# IO_SUFFIX=mc/lhc24e3/all/noConstr/$MODEL_NAME # 403
# IO_SUFFIX=data/lhc22.apass7/all/noConstr/$MODEL_NAME #976

IO_SUFFIX=HL/data/HF_LHC23_pass4_Thin_small_2P3PDstar/515291_allData # 1

INPUT_DIR=/lustre/alice/users/lubynets/bdt/outputs_apply/$IO_SUFFIX

EXE=genconfiller

OUTPUT_DIR=$PROJECT_DIR/outputs_atree/${IO_SUFFIX}
OUT_LOG_DIR=$OUTPUT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $OUT_LOG_DIR/jobs
mkdir -p $OUT_LOG_DIR/out
mkdir -p $OUT_LOG_DIR/error

cd $WORK_DIR/$INDEX

RM filelist.list

for IPT in `seq 1 5`; do
  ls -d $INPUT_DIR/pt_$IPT/appliedBdt.pt_$IPT.$INDEX.root >> filelist.list
done

$EXE filelist.list >& log_${INDEX}.txt

mv AnalysisTree.root AnalysisTree.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $OUT_LOG_DIR/jobs
CP cp $SOFT_DIR/share $EXE.cpp $OUT_LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $OUT_LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $OUT_LOG_DIR/error

cd ..
rm -r $INDEX

if [ ! -f $WORK_DIR/env.txt ]; then
echo "$OUT_LOG_DIR" > $WORK_DIR/env.txt
fi

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
