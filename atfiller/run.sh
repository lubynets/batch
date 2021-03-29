#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/atfiller/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=ATFill \
        -t 01:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 28 \
        -- $PWD/batch_run.sh