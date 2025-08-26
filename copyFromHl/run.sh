#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/ao2ds/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

A_LOW=1
A_HIGH=590
# TIME_LIMIT=12:55:00 PARTITION=long
TIME_LIMIT=08:00:00 PARTITION=main
# TIME_LIMIT=00:20:00 PARTITION=debug

A=$A_LOW-$A_HIGH

echo "Array " $A
sbatch --job-name=copyFromHl \
       --mem 16G \
       -t $TIME_LIMIT \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh
