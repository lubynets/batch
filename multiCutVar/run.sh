#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/syst/cutVar/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

A_LOW=1
A_HIGH=384
# TIME_LIMIT=00:20:00 PARTITION=debug
TIME_LIMIT=01:30:00 PARTITION=main,long

if [[ $PARTITION == "debug" ]]; then
  A_HIGH=2
fi

sbatch --job-name=cutVar \
       -t $TIME_LIMIT \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A_LOW-$A_HIGH \
       -- $PWD/batch_run.sh
