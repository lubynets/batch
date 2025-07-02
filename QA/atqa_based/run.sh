#!/bin/bash
source /lustre/alice/users/lubynets/batch/Helper.sh

LOGDIR=/lustre/alice/users/$USER/QA/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=/lustre/alice/users/lubynets/QA/workdir

A_LOW=1
A_HIGH=196
# A_HIGH=81
TIME_LIMIT=02:20:00

RM $WORK_DIR/env.txt

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
sbatch --job-name=ATQA \
       --wait \
       -t $TIME_LIMIT \
       --partition main \
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

cd $OUTPUT_LOG_DIR
mv */*tar.gz .
mv jobs/*cpp .

rm -r error out jobs
