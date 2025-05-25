#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/bdt/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

export PROJECT_DIR=/lustre/alice/users/lubynets/bdt
export WORKDIR=$PROJECT_DIR/workdir
if [ -f $WORKDIR/env.txt ]; then
rm $WORKDIR/env.txt
fi

A_LOW=1
A_HIGH=2

TIME_LIMIT=12:55:00 PARTITION=long
# TIME_LIMIT=08:00:00 PARTITION=main
# TIME_LIMIT=00:20:00 PARTITION=debug

A=$A_LOW-$A_HIGH

echo "Array " $A
sbatch --job-name=bdt \
       --mem 32G \
       -t $TIME_LIMIT \
       --wait \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh

OUTPUT_LOG_DIR=$(cat $WORKDIR/env.txt)

cd $OUTPUT_LOG_DIR/error
tar -czf err.tar.gz *.log
rm *log

cd $OUTPUT_LOG_DIR/out
tar -czf out.tar.gz *.log
rm *log

cd $OUTPUT_LOG_DIR/jobs
tar -czf jobs.tar.gz *.txt
rm *txt

cd $OUTPUT_LOG_DIR
mv */*tar.gz .

rm -r error out jobs
