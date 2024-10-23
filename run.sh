#!/bin/bash
# GROUP=cbm
GROUP=alice

LOGDIR=/lustre/$GROUP/users/$USER/test_job/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=TestJob \
        -t 00:20:00 \
        --partition debug \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 1 \
        -- $PWD/batch_run.sh
