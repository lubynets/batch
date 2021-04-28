#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/cbm2atree/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=cbm2atree \
        -t 00:20:00 \
        --partition debug \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 1-100 \
        -- $PWD/batch_run.sh