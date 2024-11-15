#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/taskd0/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

TIME=02:20:00
MODE=main
JOBS=1-862
#
# TIME=00:20:00
# MODE=main
# JOBS=1-2

sbatch --job-name=TaskD0 \
        -t $TIME \
        --partition $MODE \
        --mem 8G \
        --output=$LOGDIR/out/%a.out.log \
        --error=$LOGDIR/error/%a.err.log \
        -a $JOBS \
        -- $PWD/batch_run.sh
