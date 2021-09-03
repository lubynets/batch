#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/CbmKF/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=CbmKF \
        -t 00:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 4001-5000 \
        -- $PWD/batch_run.sh