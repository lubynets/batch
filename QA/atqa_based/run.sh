#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/QA/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=ATQA \
        -t 01:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 1-10 \
        -- $PWD/batch_run.sh