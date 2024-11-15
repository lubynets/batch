#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/taskd0

WORK_DIR=$PROJECT_DIR/workdir

MACRO_DIR=$PROJECT_DIR/macro
INPUT_DIR=/lustre/alice/users/lubynets/skim/outputs
JSON_FILE=$MACRO_DIR/dpl-config_taskd0.json
OUTPUT_DIR=$PROJECT_DIR/outputs_df
LOG_DIR=$OUTPUT_DIR/log
INPUT_FILE=$INPUT_DIR/AnalysisResults_trees.$INDEX.root

export OPTIONS="-b --configuration json://$JSON_FILE --aod-file $INPUT_FILE --aod-memory-rate-limit 2000000000 --shm-segment-size 16000000000 --resources-monitoring 2"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice/sw enter O2Physics::latest

time o2-analysis-hf-task-d0 $OPTIONS | \
o2-analysis-hf-candidate-selector-d0 $OPTIONS | \
o2-analysis-hf-candidate-creator-2prong $OPTIONS | \
o2-analysis-hf-pid-creator $OPTIONS | \
o2-analysis-pid-tpc-base $OPTIONS | \
o2-analysis-pid-tpc $OPTIONS | \
o2-analysis-pid-tof-base $OPTIONS | \
o2-analysis-pid-tof-full $OPTIONS | \
o2-analysis-timestamp $OPTIONS | \
o2-analysis-event-selection $OPTIONS | \
o2-analysis-mccollision-converter $OPTIONS | \
o2-analysis-track-propagation $OPTIONS >& log_$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

rm QAResults.root performanceMetrics.json
mv dpl-config.json dpl-config.$INDEX.json
mv AnalysisResults.root AnalysisResults.$INDEX.root
mv AnalysisResults_trees.root AnalysisResults_trees.$INDEX.root
mv *root $OUTPUT_DIR
mv *json $LOG_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX


echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
