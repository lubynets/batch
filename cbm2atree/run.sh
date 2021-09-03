#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/cbm2atree/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=cbm2atree \
        -t 01:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 6,57,62,16,48,121,130,136 \
        -- $PWD/batch_run.sh