#!/bin/bash
#####################################################################

# WHERE_TO_RUN=lustre
# WHERE_TO_RUN=tmp_jobonly
WHERE_TO_RUN=tmp_jobandinput

A_LOW=1
A_HIGH=276
# TIME_LIMIT=00:20:00 PARTITION=debug
TIME_LIMIT=00:20:00 PARTITION=main
# TIME_LIMIT=00:20:00 PARTITION=long

IS_ARCHIVE_LOGS=true
# IS_ARCHIVE_LOGS=false

#####################################################################
if [[ $PARTITION == "debug" ]]; then
  A_HIGH=2
fi

source /lustre/alice/users/lubynets/batch/Helper.sh

PROJECT_DIR=/lustre/alice/users/lubynets/ali2atree

LOGDIR=$PROJECT_DIR/log
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

WORK_DIR=$PROJECT_DIR/workdir

RM $WORK_DIR/env.txt

NOT_COMPLETED=true
ROUNDS=0
A_HIGH=$(($A_HIGH+1))
while [[ $NOT_COMPLETED = true && $ROUNDS < 5 ]]; do
date
ROUNDS=$(($ROUNDS+1))
NOT_COMPLETED=false

A=$(CreateJobsArray $A_LOW $A_HIGH $WORK_DIR/success)
if [ ! -z $A ]; then
NOT_COMPLETED=true
fi

if [ $NOT_COMPLETED = true ]; then
echo "ROUND = "$ROUNDS
echo "Array " $A
sbatch --job-name=ali2atree \
       --mem 16G \
       --wait \
       -t $TIME_LIMIT \
       --partition $PARTITION \
       --output=$LOGDIR/out/%a.out.log \
       --error=$LOGDIR/error/%a.err.log \
       -a $A \
       -- $PWD/batch_run.sh $WHERE_TO_RUN
fi
done

OUTPUT_LOG_DIR=$(cat $WORK_DIR/env.txt)

if [[ $IS_ARCHIVE_LOGS = true ]]; then
  cd $LOGDIR/out
  tar -czf out.tar.gz *.log

  cd $LOGDIR/error
  tar -czf err.tar.gz *.log

  cd ..

  mv */*tar.gz $OUTPUT_LOG_DIR

  cd $OUTPUT_LOG_DIR/jobs
  tar -czf jobs.tar.gz *.txt

  cd ..
  mv */*tar.gz .
  rm -r jobs
else
  cd $LOGDIR
  mv out $OUTPUT_LOG_DIR
  mv error $OUTPUT_LOG_DIR
fi
