#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/alice/users/lubynets/.export_tokens.sh

export GROUP=alice

export INDEX=${SLURM_ARRAY_TASK_ID}

export PROJECT_DIR=/lustre/$GROUP/users/lubynets/tasklc

export WORK_DIR=$PROJECT_DIR/workdir
export LOG_DIR=$PROJECT_DIR/outputs/log

export MACRO_DIR=$PROJECT_DIR/macro
export FILE_LIST_DIR=$PROJECT_DIR/filelists
export JSON_FILE=$MACRO_DIR/dpl-config_tasklc.json
export INPUT_FILE_LIST=$FILE_LIST_DIR/fst.$INDEX.list
export OUTPUT_DIR=$PROJECT_DIR/outputs

export OPTIONS="-b --configuration json://$JSON_FILE --aod-file @$INPUT_FILE_LIST --aod-memory-rate-limit 2000000000 --shm-segment-size 16000000000 --resources-monitoring 2"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

singularity shell -B /cvmfs -B /lustre  /lustre/alice/users/lubynets/singularities/singularity_o2deploy.sif <<\EOF
alienv -w /opt/alibuild/sw enter O2Physics::latest

o2-analysis-hf-task-lc $OPTIONS | \
o2-analysis-hf-tree-creator-lc-to-p-k-pi $OPTIONS | \
o2-analysis-centrality-table $OPTIONS | \
o2-analysis-multiplicity-table $OPTIONS | \
o2-analysis-hf-candidate-selector-lc $OPTIONS | \
o2-analysis-pid-tpc $OPTIONS | \
o2-analysis-pid-tpc-base $OPTIONS | \
o2-analysis-pid-tof-full $OPTIONS | \
o2-analysis-pid-tof-base $OPTIONS | \
o2-analysis-hf-pid-creator $OPTIONS | \
o2-analysis-hf-candidate-creator-3prong $OPTIONS | \
o2-analysis-timestamp $OPTIONS | \
o2-analysis-event-selection $OPTIONS | \
o2-analysis-mccollision-converter $OPTIONS | \
o2-analysis-track-propagation $OPTIONS >& log_$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

rm QAResults.root performanceMetrics.json
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
