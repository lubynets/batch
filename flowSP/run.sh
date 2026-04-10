#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/flowSP/log
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

A_LOW=1
A_HIGH=3

## Use debag partition for testing only. The time limit for debug is 00:30:00
## Time limit for main 08:00:00
## Time limit for long 7-00:00:00
## Enumerate main,long with a comma in order to allow the scheduler submission at any of them (which is earlier available)

# TIME_LIMIT=00:20:00 PARTITION=debug
TIME_LIMIT=01:30:00 PARTITION=main,long

## Do not submit more than 1 debug job
if [[ $PARTITION == "debug" ]]; then
  A_HIGH=1
fi

JOBS_ARRAY=$A_LOW-$A_HIGH
# JOBS_ARRAY=2,3,5,7,11
# JOBS_ARRAY=1-5,10-20

sbatch --job-name=flowSP \
       --mem 16G \
       -t $TIME_LIMIT \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $JOBS_ARRAY \
       -- $PWD/batch_run.sh
