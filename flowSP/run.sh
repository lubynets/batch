#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/flowSP/log
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

A_LOW=1
A_HIGH=3

# TIME_LIMIT=00:20:00 PARTITION=debug
TIME_LIMIT=01:30:00 PARTITION=main,long

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
