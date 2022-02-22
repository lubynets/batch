#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/qna/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/QnAnalysis
# BUILD_DIR=build_atv2compat
BUILD_DIR=build_master
WORK_DIR=/lustre/cbm/users/$USER/qna/workdir

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/src/QnAnalysisBase
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/src/QnAnalysisCorrelate
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/_deps/qntools-build/src/base
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/_deps/qntools-build/src/correction

A_LOW=1
A_HIGH=100
TIME_LIMIT=00:20:00

for STEP in `seq 0 2`
do

echo
echo $STEP

# if [ $STEP -eq 2 ]
# then
# TIME_LIMIT=00:08:00
# fi

STEP_NOT_COMPLETED=true
while [ $STEP_NOT_COMPLETED = true ]
do
date

STEP_NOT_COMPLETED=false
A=

for X in `seq $A_LOW $A_HIGH`
do
if ! [ -f $WORK_DIR/success/step_${STEP}_index_${X} ]
then
STEP_NOT_COMPLETED=true
A=$A,$X
fi
done

if [ $STEP_NOT_COMPLETED = true ]
then
sbatch --job-name=QnA \
       --wait \
       -t $TIME_LIMIT \
       --partition main \
       --output=$LOGDIR/out/%j.out.log \
       --error=$LOGDIR/error/%j.err.log \
       -a $A \
       -- $PWD/batch_run.sh $STEP
fi
done

if [ $STEP -ne 2 ]
then
hadd -T $WORK_DIR/correction_merged_out_$STEP.root $WORK_DIR/*/correction_out_$STEP.root >& $LOGDIR/log_merge_$STEP.txt
fi

done
