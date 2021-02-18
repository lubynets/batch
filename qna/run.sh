#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/qna/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=QnA \
        -t 07:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 1-10 \
        -- $PWD/batch_run.sh