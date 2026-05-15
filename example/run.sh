#!/bin/bash

echo "run.sh started"
hostname

LOGDIR=/lustre/alice/users/$USER/QA/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

sbatch --job-name=MacroQA \
       -t 00:20:00 \
       --partition main \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a 1-2 \
       -- $PWD/batch_run.sh

echo "run.sh finished"
