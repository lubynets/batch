#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/CSTlc

WORK_DIR=$PROJECT_DIR/workdir

SKIM_SELECTION=lhc24e3
# SKIM_SELECTION=relax

CONFIG_DIR=$PROJECT_DIR/config
INPUT_DIR=/lustre/alice/users/lubynets/skim/outputs/$SKIM_SELECTION
JSON_FILE=$CONFIG_DIR/dpl-config_CSTlc.json
OUTPUT_DIR=$PROJECT_DIR/outputs/signalOnly/$SKIM_SELECTION
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log
INPUT_FILE=$INPUT_DIR/AnalysisResults_trees.$INDEX.root

export OPTIONS="-b --configuration json://$JSON_FILE --aod-file $INPUT_FILE --aod-memory-rate-limit 524288000 --shm-segment-size 10200547328 --resources-monitoring 2 --aod-parent-access-level 1 --aod-writer-keep AOD/HFCANDLCLITE/0,AOD/HFCANDLCKF/0,AOD/HFCANDLCMC/0"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice/sw enter O2Physics::latest

o2-analysis-hf-tree-creator-lc-to-p-k-pi $OPTIONS | \
o2-analysis-multiplicity-table $OPTIONS | \
o2-analysis-centrality-table $OPTIONS | \
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
mv *json $LOG_DIR/jobs
mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
if [ -f $OUTPUT_DIR/AnalysisResults_trees.$INDEX.root ]
then
touch index_${INDEX}
fi

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
