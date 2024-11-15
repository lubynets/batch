#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/cresellc

WORK_DIR=$PROJECT_DIR/workdir

CONFIG_DIR=$PROJECT_DIR/config
INPUT_DIR=/lustre/alice/users/lubynets/skim/outputs_3prong
JSON_FILE=$CONFIG_DIR/dpl-config_cresellc.json
OUTPUT_DIR=$PROJECT_DIR/outputs/KF
LOG_DIR=$OUTPUT_DIR/log
INPUT_FILE=$INPUT_DIR/AnalysisResults_trees.$INDEX.root

export OPTIONS="-b --configuration json://$JSON_FILE --aod-file $INPUT_FILE --aod-memory-rate-limit 2000000000 --shm-segment-size 16000000000 --resources-monitoring 2 --aod-writer-keep AOD/HFCAND3PBASE/0,AOD/HFCAND3PMCGEN/0,AOD/HFCAND3PMCREC/0,AOD/HFSELLC/0,DYN/HFCAND3PEXT/0,AOD/HFCANDLCFULL/0,AOD/HFCANDLCLITE/0,AOD/HFCOLLIDLCLITE/0,AOD/HFCANDLCFULLEV/0,AOD/HFCANDLCFULLP/0,AOD/HFCAND3PKF/0"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice/sw enter O2Physics::latest

time o2-analysis-hf-task-lc $OPTIONS | \
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
