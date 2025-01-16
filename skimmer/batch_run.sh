#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/skim

SKIM_SELECTION=lhc22.apass7
# SKIM_SELECTION=lhc24e3
# SKIM_SELECTION=relax

WORK_DIR=$PROJECT_DIR/workdir
OUTPUT_DIR=$PROJECT_DIR/outputs/data/$SKIM_SELECTION
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log
MACRO_DIR=$PROJECT_DIR/config
FILE_LIST_DIR=$PROJECT_DIR/filelists/data
JSON_FILE=$MACRO_DIR/dpl-config_skim.$SKIM_SELECTION.json
INPUT_FILE_LIST=$FILE_LIST_DIR/fst.$INDEX.list

export OPTIONS="-b --aod-file @$INPUT_FILE_LIST --configuration json://$JSON_FILE --aod-memory-rate-limit 524288000 --shm-segment-size 10200547328 --resources-monitoring 2 --aod-writer-keep AOD/HF2PRONG/1,AOD/HF3PRONG/1"
# export OPTIONS="-b --aod-file @$INPUT_FILE_LIST --configuration json://$JSON_FILE --aod-memory-rate-limit 524288000 --shm-segment-size 10200547328 --resources-monitoring 2 --aod-writer-keep AOD/HF2PRONG/1,AOD/HF3PRONG/1,AOD/HFPVREFIT2PRONG/0,AOD/HFPVREFIT3PRONG/0"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/config
mkdir -p $LOG_DIR/job
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice/sw enter O2Physics::latest

time o2-analysis-hf-track-index-skim-creator $OPTIONS | \
o2-analysis-pid-tpc-base $OPTIONS | \
o2-analysis-pid-tpc $OPTIONS | \
o2-analysis-timestamp $OPTIONS | \
o2-analysis-trackselection $OPTIONS | \
o2-analysis-track-propagation $OPTIONS | \
o2-analysis-event-selection $OPTIONS | \
o2-analysis-tracks-extra-v002-converter $OPTIONS | \
o2-analysis-track-to-collision-associator $OPTIONS >& log_$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

rm performanceMetrics.json
mv dpl-config.json dpl-config.$INDEX.json
mv AnalysisResults.root AnalysisResults.$INDEX.root
mv AnalysisResults_trees.root AnalysisResults_trees.$INDEX.root
mv *root $OUTPUT_DIR
mv *json $LOG_DIR/config
mv log* $LOG_DIR/job
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
