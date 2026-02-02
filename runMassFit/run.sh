#!/bin/bash
source /lustre/alice/users/lubynets/batch/Helper.sh

LOGDIR=/lustre/alice/users/$USER/QA/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=/lustre/alice/users/lubynets/QA/workdir

A_LOW=1
A_HIGH=100
# TIME_LIMIT=00:20:00 PARTITION=debug
# TIME_LIMIT=01:20:00 PARTITION=main
TIME_LIMIT=00:25:00 PARTITION=long

if [[ $PARTITION == "debug" ]]; then
  A_HIGH=2
fi

NOT_COMPLETED=true
ROUNDS=0
A_HIGH=$(($A_HIGH+1))
while [[ $NOT_COMPLETED = true && $ROUNDS < 5 ]]
do
date

NOT_COMPLETED=false

A=$(CreateJobsArray $A_LOW $A_HIGH $WORK_DIR/success)
if [ ! -z $A ]; then
NOT_COMPLETED=true
fi

if [ $NOT_COMPLETED = true ]
then
echo "Array " $A
sbatch --job-name=MacroQA \
       --wait \
       -t $TIME_LIMIT \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh $PARTITION
fi
ROUNDS=$(($ROUNDS+1))
done
