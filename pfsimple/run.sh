#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/pfsimple/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

echo 11

sbatch  --job-name=PFSimple \
        --wait \
        -t 07:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 1-1 \
        -- $PWD/batch_run.sh
        
echo 22
        
sbatch  --job-name=PFSimple \
        --wait \
        -t 07:20:00 \
        --partition main \
        --output=$LOGDIR/out/%j.out.log \
        --error=$LOGDIR/error/%j.err.log \
        -a 2-2 \
        -- $PWD/batch_run.sh
        
