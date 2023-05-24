#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/qna/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh
SOFT_DIR=/lustre/cbm/users/lubynets/soft/QnAnalysis
INSTALL_DIR=install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$INSTALL_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/QnTools

WORK_DIR=/lustre/cbm/users/$USER/qna/workdir

A_LOW=1
A_HIGH=100

# NSTEPS=1 # PLAIN
# NSTEPS=2 # RECENTERING
NSTEPS=3 # TWIST^RESCALE

TIME_LIMIT=00:10:00

A_HIGH=$(($A_HIGH+1))

for STEP in `seq 0 $NSTEPS`
do

echo
echo $STEP

STEP_NOT_COMPLETED=true
while [ $STEP_NOT_COMPLETED = true ]
do
date

STEP_NOT_COMPLETED=false
A=

for X in `seq $A_LOW $A_HIGH`
do
if [[ ! -f $WORK_DIR/success/step_${STEP}_index_${X} && ! $X = $A_HIGH ]]
then
STEP_NOT_COMPLETED=true
if [ -z $START_INTERVAL ]
then
START_INTERVAL=$X
fi
FINISH_INTERVAL=$X
else
if [ $START_INTERVAL = $FINISH_INTERVAL ]
then
INTERVAL=$START_INTERVAL
else
INTERVAL=$START_INTERVAL-$FINISH_INTERVAL
fi
if ! [ -z $INTERVAL ]
then
if [ -z $A ]
then
A=$INTERVAL
else
A=$A,$INTERVAL
fi
fi
START_INTERVAL=
FINISH_INTERVAL=
INTERVAL=
fi
done

if [ $STEP_NOT_COMPLETED = true ]
then
echo "Array " $A
sbatch --job-name=QnA \
       --wait \
       -t 00:10:00 \
       --partition main \
       --output=$LOGDIR/out/%j.out.log \
       --error=$LOGDIR/error/%j.err.log \
       -a $A \
       -- $PWD/batch_run.sh $STEP $NSTEPS
fi
done

if [ $STEP -lt $(($NSTEPS-1)) ]
then
hadd -T $WORK_DIR/correction_merged_out_$STEP.root $WORK_DIR/*/correction_out_$STEP.root >& $LOGDIR/log_merge_$STEP.txt
fi

done
