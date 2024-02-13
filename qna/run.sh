#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/qna/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

source /lustre/cbm/users/lubynets/soft/QnAnalysis/install/bin/QnAnalysisConfig.sh

WORK_DIR=/lustre/cbm/users/$USER/qna/workdir

A_LOW=1
A_HIGH=2

# NSTEPS=1 # PLAIN
# NSTEPS=2 # RECENTERING
NSTEPS=3 # TWIST&RESCALE

TIME_LIMIT=00:15:00

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
       -t $TIME_LIMIT \
       --partition main \
       --output=$LOGDIR/out/%a.step_${STEP}.out.log \
       --error=$LOGDIR/error/%a.step_${STEP}.err.log \
       -a $A \
       -- $PWD/batch_run.sh $STEP $NSTEPS
fi
done

if [ $STEP -lt $(($NSTEPS-1)) ]
then
hadd -T $WORK_DIR/correction_merged_out_$STEP.root $WORK_DIR/*/correction_out_$STEP.root >& $LOGDIR/log_merge_$STEP.txt
fi

done
