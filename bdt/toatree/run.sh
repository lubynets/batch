#!/bin/bash
source /lustre/alice/users/lubynets/batch/Helper.sh

export PROJECT_DIR=/lustre/alice/users/lubynets/bdt

export BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $BATCH_LOG_DIR/out
mkdir -p $BATCH_LOG_DIR/error

export WORK_DIR=$PROJECT_DIR/workdir

BATCH_DIR=$PWD

RM $WORKDIR/env.txt

A_LOW=1
A_HIGH=1
TIME_LIMIT=00:20:00

NOT_COMPLETED=true
ROUNDS=0
A_HIGH=$(($A_HIGH+1))
while [[ $NOT_COMPLETED = true && $ROUNDS < 5 ]]
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
sbatch --job-name=bdt2atree \
       --wait \
       -t $TIME_LIMIT \
       --mem 16G \
       --partition main \
       --output=$BATCH_LOG_DIR/out/%a.out.log \
       --error=$BATCH_LOG_DIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh
fi
ROUNDS=$(($ROUNDS+1))
done

OUTPUT_LOG_DIR=$(cat $WORK_DIR/env.txt)

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
mv jobs/*cpp .

cp $BATCH_DIR/*sh .
chmod -x *sh

rm -r error out jobs

