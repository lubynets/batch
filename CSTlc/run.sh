#!/bin/bash

LOGDIR=/lustre/alice/users/$USER/CSTlc/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=/lustre/alice/users/$USER/CSTlc/workdir

BATCH_DIR=$PWD

A_LOW=1
A_HIGH=2
# TIME_LIMIT=12:55:00 PARTITION=long
TIME_LIMIT=08:00:00 PARTITION=main
# TIME_LIMIT=00:20:00 PARTITION=debug

if [ -f $WORK_DIR/env.txt ]; then
rm $WORK_DIR/env.txt
fi

NOT_COMPLETED=true
ROUNDS=0
A_HIGH=$(($A_HIGH+1))
while [[ $NOT_COMPLETED = true && $ROUNDS < 1 ]]
do
date

NOT_COMPLETED=false
A=

for X in `seq $A_LOW $A_HIGH`
do
if [[ ! -f $WORK_DIR/success/index_${X} && ! $X = $A_HIGH ]]
then
NOT_COMPLETED=true
if [ -z $START_INTERVAL ]
then
START_INTERVAL=$X
fi
FINISH_INTERVAL=$X
else
if [ $START_INTERVAL = $FINISH_INTERVAL ]
then
INTERVAL=$START_INTERVAL
else
INTERVAL=$START_INTERVAL-$FINISH_INTERVAL
fi
if ! [ -z $INTERVAL ]
then
if [ -z $A ]
then
A=$INTERVAL
else
A=$A,$INTERVAL
fi
fi
START_INTERVAL=
FINISH_INTERVAL=
INTERVAL=
fi
done

if [ $NOT_COMPLETED = true ]
then
echo "Array " $A
sbatch --job-name=CSTlc \
       --mem 16G \
       --wait \
       -t $TIME_LIMIT \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh
fi
ROUNDS=$(($ROUNDS+1))
done

OUTPUT_LOG_DIR=$(cat $WORK_DIR/env.txt)

cd $OUTPUT_LOG_DIR/error
tar -czf err.tar.gz *.log

cd $OUTPUT_LOG_DIR/out
tar -czf out.tar.gz *.log

cd $OUTPUT_LOG_DIR/jobs
tar -czf jobs.tar.gz *.txt
tar -czf jsons.tar.gz *.json

cd $OUTPUT_LOG_DIR
mv */*tar.gz .

cp $BATCH_DIR/*sh .
chmod -x *sh

# rm -r error out jobs
