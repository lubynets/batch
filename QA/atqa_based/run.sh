#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/QA/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=/lustre/cbm/users/lubynets/QA/workdir

A_LOW=1
A_HIGH=5
TIME_LIMIT=02:20:00

NOT_COMPLETED=true
while [ $NOT_COMPLETED = true ]
do
date

NOT_COMPLETED=false
A=

for X in `seq $A_LOW $A_HIGH`
do
if ! [ -f $WORK_DIR/success/index_${X} ]
then
NOT_COMPLETED=true
A=$A,$X
fi
done

if [ $NOT_COMPLETED = true ]
then
sbatch --job-name=ATQA \
       --wait \
       -t $TIME_LIMIT \
       --partition main \
       --output=$LOGDIR/out/%j.out.log \
       --error=$LOGDIR/error/%j.err.log \
       -a $A \
       -- $PWD/batch_run.sh
fi
done