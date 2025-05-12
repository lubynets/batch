#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/bdt

WORK_DIR=$PROJECT_DIR/workdir
OUTPUT_DIR=$PROJECT_DIR/outputs_train/moreMoreCuts
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

export CONFIG_DIR=$PROJECT_DIR/config
export MACRO_DIR=$PROJECT_DIR/macro

export INPUT_DIR_MC=/lustre/alice/users/lubynets/plainer/outputs/mc/lhc24e3/sig_bgsup100/noConstr
export INPUT_FILES_MC_FROM=1
export INPUT_FILES_MC_TO=403
export INPUT_FILES_DATA_FROM=1
if [[ $INDEX < 3 ]]; then
export INPUT_DIR_DATA=/lustre/alice/users/lubynets/plainer/outputs/data/lhc22.apass7/all/noConstr/noSel/sidebands/loPt
export INPUT_FILES_DATA_TO=50
else
export INPUT_DIR_DATA=/lustre/alice/users/lubynets/plainer/outputs/data/lhc22.apass7/all/noConstr/noSel/sidebands/hiPt
export INPUT_FILES_DATA_TO=976
fi

export MODEL_DIR=$OUTPUT_DIR/model/$INDEX
export OUT_DIR=$OUTPUT_DIR/out/$INDEX

PT_RANGES=('0' '2' '5' '8' '12' '20')
export PT_LO=${PT_RANGES[$(($INDEX-1))]}
export PT_HI=${PT_RANGES[$INDEX]}

mkdir -p $WORK_DIR/$INDEX
mkdir -p $MODEL_DIR
mkdir -p $OUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

apptainer shell /lustre/alice/users/lubynets/singularities/bdt.sif << \EOF
source /usr/local/install/bin/thisroot.sh

python3 $MACRO_DIR/train_multi_class_BDT.py --config-file $CONFIG_DIR/config.train.yaml \
                                            --config-file-sel $CONFIG_DIR/config.train_selection.yaml \
                                            --input-files-mc-path $INPUT_DIR_MC/PlainTree \
                                            --input-files-mc-range $INPUT_FILES_MC_FROM $INPUT_FILES_MC_TO \
                                            --input-files-data-path $INPUT_DIR_DATA/PlainTree \
                                            --input-files-data-range $INPUT_FILES_DATA_FROM $INPUT_FILES_DATA_TO \
                                            --output-directory $OUT_DIR \
                                            --model-directory $MODEL_DIR \
                                            --slice-var-interval $PT_LO $PT_HI >& log_$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

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
