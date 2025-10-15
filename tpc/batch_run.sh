#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/tpc

IO_PREFIX=alice/data/2023/LHC23zzo/545210/apass5/2020

WORK_DIR=$PROJECT_DIR/workdir
CONFIG_DIR=$PROJECT_DIR/config
OUTPUT_DIR=$PROJECT_DIR/outputs/${IO_PREFIX}/tofCut/default
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

export INPUT_FILE=@/lustre/alice/users/lubynets/ao2ds/$IO_PREFIX/filelists/fst.$INDEX.list
export CONFIG_FILE=$CONFIG_DIR/configuration.json
export OUTPUT_DIRECTOR_FILE=$CONFIG_DIR/OutputDirector.json

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice2/sw enter O2Physics::latest

o2-analysis-pid-tof-merge -b --configuration json://$CONFIG_FILE | \
o2-analysis-ft0-corrected-table -b --configuration json://$CONFIG_FILE | \
o2-analysis-pid-tpc-qa -b --configuration json://$CONFIG_FILE | \
o2-analysis-dq-v0-selector -b --configuration json://$CONFIG_FILE | \
o2-analysis-multcenttable -b --configuration json://$CONFIG_FILE | \
o2-analysis-event-selection-service -b --configuration json://$CONFIG_FILE | \
o2-analysis-propagationservice -b --configuration json://$CONFIG_FILE | \
o2-analysis-pid-tpc-skimscreation -b --configuration json://$CONFIG_FILE | \
o2-analysis-pid-tpc-service -b --configuration json://$CONFIG_FILE | \
o2-analysis-trackselection -b --configuration json://$CONFIG_FILE \
--aod-file $INPUT_FILE \
--aod-writer-json $OUTPUT_DIRECTOR_FILE >& log_$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

rm network.onnx QAResults.root
mv dpl-config.json dpl-config.$INDEX.json
mv AnalysisResults.root AnalysisResults.$INDEX.root
mv AO2D.root AO2D.$INDEX.root
mv *root $OUTPUT_DIR
mv *json $LOG_DIR/jobs
mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
if [ -f $OUTPUT_DIR/AO2D.$INDEX.root ]
then
touch index_${INDEX}
fi

if [ ! -f $WORK_DIR/env.txt ]; then
echo "$LOG_DIR" > $WORK_DIR/env.txt
fi

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
