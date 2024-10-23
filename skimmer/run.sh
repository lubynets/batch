#!/bin/bash
GROUP=alice

LOGDIR=/lustre/$GROUP/users/$USER/skim/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=Skim \
        -t 00:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 3001-6031 \
        -- $PWD/batch_run.sh
