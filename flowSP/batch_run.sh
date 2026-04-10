#!/bin/bash

echo
echo "Bash script started"
date
hostname

START_TIME=$SECONDS

## Variables, related to Grid tokens and those, which are used inside the apptainer shell (between the two EOF keywords) must be declared with export
## Other variables can be declared without export
export JALIEN_TOKEN_CERT=/lustre/alice/users/$USER/token/tokencert_${UID}.pem
export JALIEN_TOKEN_KEY=/lustre/alice/users/$USER/token/tokenkey_${UID}.pem
export alien_CLOSE_SE=ALICE::CERN::OCDB
export ALIEN_SITE=CERN
unset http_proxy https_proxy

export INDEX=${SLURM_ARRAY_TASK_ID}

## Set the trees which you want to save in the AnalysisResults_trees.root file. The Zdc tree is added as an example for illustrative purposes. Optimize the list of trees to be saved acoording to the needs of your analysis.
## You may consider uncommenting the next line, but keep in mind that the execution time will increase dramatically.
# export TREES_TO_SAVE=AOD/TRACK/0,AOD/COLLISION/1,AOD/TRACKEXTRA/2,AOD/TRACKDCA/0,AOD/pidTPCFullPr/0,AOD/pidTPCFullPi/0,AOD/pidTPCFullKa/0,AOD/pidTOFFullPr/0,AOD/pidTOFFullPi/0,AOD/pidTOFFullKa/0,AOD/pidTOFbeta/0,AOD/TOFEvTime/0,AOD/TOFSignal/0,AOD/SPZDC/0
export TREES_TO_SAVE=AOD/SPZDC/0

PROJECT_DIR=/lustre/alice/users/$USER/flowSP

WORK_DIR=$PROJECT_DIR/workdir
CONFIG_DIR=$PROJECT_DIR/config
OUTPUT_DIR=$PROJECT_DIR/outputs
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log
FILELIST_DIR=$PROJECT_DIR/filelists

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

export INPUT_FILE=@/$FILELIST_DIR/filelist.$INDEX.list
export CONFIG_FILE=$CONFIG_DIR/configuration.json

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/akonings/alice/sw enter O2Physics::latest

o2-analysis-pid-tof-merge -b --configuration json://$CONFIG_FILE | \
o2-analysis-ft0-corrected-table -b --configuration json://$CONFIG_FILE | \
o2-analysis-multcenttable -b --configuration json://$CONFIG_FILE | \
o2-analysis-event-selection-service -b --configuration json://$CONFIG_FILE | \
o2-analysis-propagationservice -b --configuration json://$CONFIG_FILE | \
o2-analysis-pid-tpc-service -b --configuration json://$CONFIG_FILE | \
o2-analysis-track-to-collision-associator -b --configuration json://$CONFIG_FILE | \
o2-analysis-cf-zdc-q-vectors -b --configuration json://$CONFIG_FILE | \
o2-analysis-cf-flow-sp -b --configuration json://$CONFIG_FILE | \
o2-analysis-trackselection -b --configuration json://$CONFIG_FILE \
--aod-file $INPUT_FILE \
--shm-segment-size 16000000000 \
--aod-writer-keep $TREES_TO_SAVE \
>& log_$INDEX.txt

EOF

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

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
