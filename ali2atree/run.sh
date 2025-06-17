#!/bin/bash
source /lustre/alice/users/lubynets/batch/Helper.sh

export PROJECT_DIR=/lustre/alice/users/lubynets/ali2atree
LOGDIR=$PROJECT_DIR/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=$PROJECT_DIR/workdir

BATCH_DIR=$PWD

A_LOW=1
A_HIGH=403
TIME_LIMIT=00:20:00

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
sbatch --job-name=ali2atree \
       --wait \
       -t $TIME_LIMIT \
       --mem 16G \
       --partition main \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh
fi
ROUNDS=$(($ROUNDS+1))
done

echo
date
echo "Jobs are done"
echo

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

cp $BATCH_DIR/*sh .
chmod -x *sh

rm -r error out jobs

echo
date
echo "Logs are archived. Finish."
echo
