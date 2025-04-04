#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/skim/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=/lustre/alice/users/$USER/skim/workdir

A_LOW=1
A_HIGH=403
TIME_LIMIT=03:40:00

NOT_COMPLETED=true
ROUNDS=0
A_HIGH=$(($A_HIGH+1))
while [[ $NOT_COMPLETED = true && $ROUNDS < 2 ]]
do
date

NOT_COMPLETED=false
A=

for X in `seq $A_LOW $A_HIGH`
do
if [[ ! -f $WORK_DIR/success/index_${X} && ! $X = $A_HIGH ]]
then
NOT_COMPLETED=true
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

if [ $NOT_COMPLETED = true ]
then
echo "Array " $A
sbatch --job-name=Skim \
       --mem 16G \
       --wait \
       -t $TIME_LIMIT \
       --partition main \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh
fi
ROUNDS=$(($ROUNDS+1))
done
