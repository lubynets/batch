#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/CSTlc

WORK_DIR=$PROJECT_DIR/workdir

# RUN_MODE=smallTest
RUN_MODE=greatRun

# SKIM_SELECTION=lhc22.apass7 MC_OR_DATA=data #976
SKIM_SELECTION=lhc24e3 MC_OR_DATA=mc #403

SIG_BG=all
# SIG_BG=sig_bgsup100
# SELECTION=noSel_ML

CONSTRAINT=noConstr
# CONSTRAINT=topoConstr
# CONSTRAINT=minvConstr

TREES_TO_SAVE=AOD/HFCANDLCLITE/0,AOD/HFCANDLCKF/0,AOD/HFCANDLCFULLEV/0,AOD/HFCOLLIDLCLITE/0

if [[ $MC_OR_DATA = "mc" ]]; then
TREES_TO_SAVE=${TREES_TO_SAVE},AOD/HFCANDLCMC/0,AOD/HFCANDLCFULLP/0
fi

CONFIG_DIR=$PROJECT_DIR/config
INPUT_DIR=/lustre/alice/users/lubynets/skim/outputs/$MC_OR_DATA/$SKIM_SELECTION
JSON_FILE=$CONFIG_DIR/dpl-config_CSTlc_$MC_OR_DATA.json
if [[ $RUN_MODE = "greatRun" ]]; then
  INPUT_FILE=$INPUT_DIR/AnalysisResults_trees.$INDEX.root
  OUTPUT_DIR=$PROJECT_DIR/outputs/$MC_OR_DATA/$SKIM_SELECTION/$SIG_BG/$CONSTRAINT/moreMoreVarsWoPid
elif [[ $RUN_MODE = "smallTest" ]]; then
  if [[ $MC_OR_DATA = "mc" ]]; then
    INPUT_FILE=/lustre/alice/users/lubynets/ao2ds/sim/2024/LHC24e3/0/526641/AOD/001/AnalysisResults_skimmed.small.root
  else
    INPUT_FILE=/lustre/alice/users/lubynets/ao2ds/data/2022/LHC22o/526641/apass7/0630/o2_ctf_run00526641_orbit0206830848_tf0000000001_epn160/001/AO2D.skimmed.small.root
  fi
OUTPUT_DIR=$PROJECT_DIR/outputs/draft
fi
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

export OPTIONS="-b --configuration json://$JSON_FILE --aod-file $INPUT_FILE --aod-memory-rate-limit 524288000 --shm-segment-size 10200547328 --resources-monitoring 2 --aod-parent-access-level 1 --aod-writer-keep $TREES_TO_SAVE"

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice/sw enter O2Physics::latest

o2-analysis-hf-task-lc $OPTIONS | \
o2-analysis-hf-tree-creator-lc-to-p-k-pi $OPTIONS | \
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
o2-analysis-tracks-extra-v002-converter $OPTIONS | \
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

if [ ! -f $WORK_DIR/env.txt ]; then
echo "$LOG_DIR" > $WORK_DIR/env.txt
fi

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
