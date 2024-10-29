#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/skim/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=Skim \
        -t 01:20:00 \
        --partition main \
        --output=$LOGDIR/out/%a.out.log \
        --error=$LOGDIR/error/%a.err.log \
        -a 1-862 \
        -- $PWD/batch_run.sh
