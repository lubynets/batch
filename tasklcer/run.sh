#!/bin/bash
GROUP=alice

LOGDIR=/lustre/$GROUP/users/$USER/tasklc/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=TaskLc \
        -t 01:20:00 \
        --partition main \
        --mem 8G \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 3-601 \
        -- $PWD/batch_run.sh
