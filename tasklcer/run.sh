#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/tasklc/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=TaskLc \
        -t 02:20:00 \
        --partition main \
        --mem 8G \
        --output=$LOGDIR/out/%a.out.log \
        --error=$LOGDIR/error/%a.err.log \
        -a 1-862 \
        -- $PWD/batch_run.sh
