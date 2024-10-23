#!/bin/bash

echo
echo "Bash script started"
date

export GROUP=alice

export INDEX=${SLURM_ARRAY_TASK_ID}

export PROJECT_DIR=/lustre/$GROUP/users/lubynets/test_job

export OUTPUT_DIR=$PROJECT_DIR/outputs
export WORK_DIR=$PROJECT_DIR/workdir
export LOG_DIR=$OUTPUT_DIR/log

export INPUT_DIR=$PROJECT_DIR/input
export EXE=o2-analysistutorial-mm-my-example-task

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

singularity shell -B /cvmfs -B /lustre  /lustre/alice/users/lubynets/alice/singularity_o2deploy.sif <<\EOF
alienv -w /opt/alibuild/sw enter O2Physics::latest

mkdir $OUTPUT_DIR/123

$EXE -b --aod-file $INPUT_DIR/AO2D.root >& log_${INDEX}.txt

mkdir $OUTPUT_DIR/456

# EOF to trigger the end of the singularity command
EOF

mv AnalysisResults.root AnalysisResults.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX


echo
echo "Bash script finished successfully"
date
