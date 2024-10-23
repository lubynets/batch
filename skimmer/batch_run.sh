#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/alice/users/lubynets/.export_tokens.sh

export GROUP=alice

export INDEX=${SLURM_ARRAY_TASK_ID}

export PROJECT_DIR=/lustre/$GROUP/users/lubynets/skim

export WORK_DIR=$PROJECT_DIR/workdir
export LOG_DIR=$PROJECT_DIR/outputs/log

export INPUT_DIR=/lustre/alice/alien/alice/sim/2024/LHC24e3
export MACRO_DIR=$PROJECT_DIR/macro
export FILE_LIST=$MACRO_DIR/sim.2024.LHC24e3.txt
export JSON_FILE=$MACRO_DIR/dpl-config_skim.json
export FILE_PATH=$(head -$INDEX $FILE_LIST | tail -1 )
export INPUT_FILE=$INPUT_DIR/$FILE_PATH/AO2D.root
export OUTPUT_DIR=$PROJECT_DIR/outputs/$FILE_PATH

export OPTIONS="-b --aod-file $INPUT_FILE --configuration json://$JSON_FILE --aod-memory-rate-limit 2000000000 --shm-segment-size 16000000000 --resources-monitoring 2 --aod-writer-keep AOD/HF3PRONG/1"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

singularity shell -B /cvmfs -B /lustre  /lustre/alice/users/lubynets/singularities/singularity_o2deploy.sif <<\EOF
alienv -w /opt/alibuild/sw enter O2Physics::latest

o2-analysis-hf-track-index-skim-creator $OPTIONS | \
o2-analysis-timestamp $OPTIONS | \
o2-analysis-trackselection $OPTIONS | \
o2-analysis-track-propagation $OPTIONS | \
o2-analysis-track-to-collision-associator $OPTIONS >& log_$INDEX.txt

# EOF to trigger the end of the singularity command
EOF

mv *root $OUTPUT_DIR
rm performanceMetrics.json
mv *json $OUTPUT_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX


echo
echo "Bash script finished successfully"
date
