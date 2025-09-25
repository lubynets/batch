#!/bin/bash
source /lustre/alice/users/lubynets/batch/Helper.sh

LOGDIR=/lustre/alice/users/$USER/tpc/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=/lustre/alice/users/$USER/tpc/workdir

BATCH_DIR=$PWD

A_LOW=1
A_HIGH=197
TIME_LIMIT=12:55:00 PARTITION=long
# TIME_LIMIT=08:00:00 PARTITION=main
# TIME_LIMIT=00:20:00 PARTITION=debug

RM $WORK_DIR/env.txt

NOT_COMPLETED=true
ROUNDS=0
A_HIGH=$(($A_HIGH+1))
while [[ $NOT_COMPLETED = true && $ROUNDS < 1 ]]
do
date

NOT_COMPLETED=false

A=$(CreateJobsArray $A_LOW $A_HIGH $WORK_DIR/success)
if [ ! -z $A ]; then
NOT_COMPLETED=true
fi

if [ $NOT_COMPLETED = true ]
then
echo "Array " $A
sbatch --job-name=tpc \
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

rm -r error out jobs
