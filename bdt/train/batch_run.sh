#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/bdt

WORK_DIR=$PROJECT_DIR/workdir
OUTPUT_DIR=$PROJECT_DIR/outputs_train/HL3_ctwise
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

export CONFIG_DIR=$PROJECT_DIR/config
export MACRO_DIR=$PROJECT_DIR/macro

export INPUT_DIR_MC=/lustre/alice/users/lubynets/plainer/outputs/HL/mc/HF_LHC24h1b_All/515935
export INPUT_FILES_MC_FROM=1
export INPUT_FILES_MC_TO=518
export INPUT_FILES_DATA_FROM=1
export INPUT_DIR_DATA=/lustre/alice/users/lubynets/plainer/outputs/HL/data/HF_LHC23_pass4_Thin_small_2P3PDstar/515291_allData
export INPUT_FILES_DATA_TO=1131

export MODEL_DIR=$OUTPUT_DIR/model/$INDEX
export OUT_DIR=$OUTPUT_DIR/out/$INDEX

SLICE_VAR_RANGES=('0.006' '0.0105' '0.015' '0.021' '0.027' '0.048')
export SLICE_VAR_LO=${SLICE_VAR_RANGES[$(($INDEX-1))]}
export SLICE_VAR_HI=${SLICE_VAR_RANGES[$INDEX]}

# if [ $INDEX -eq 1 ]; then SIDE_BANDS=('2.20' '2.24' '2.34' '2.38'); fi
# if [ $INDEX -eq 2 ]; then SIDE_BANDS=('2.20' '2.24' '2.34' '2.38'); fi
# if [ $INDEX -eq 3 ]; then SIDE_BANDS=('2.20' '2.24' '2.34' '2.38'); fi
# if [ $INDEX -eq 4 ]; then SIDE_BANDS=('2.20' '2.24' '2.34' '2.38'); fi
# if [ $INDEX -eq 5 ]; then SIDE_BANDS=('2.20' '2.24' '2.34' '2.38'); fi
# if [ $INDEX -eq 6 ]; then SIDE_BANDS=('2.20' '2.24' '2.34' '2.38'); fi
# if [ $INDEX -eq 7 ]; then SIDE_BANDS=('2.20' '2.22' '2.37' '2.39'); fi
# if [ $INDEX -eq 8 ]; then SIDE_BANDS=('2.19' '2.21' '2.38' '2.40'); fi

SIDE_BANDS=('2.12' '2.20' '2.38' '2.42')

export SBLE=${SIDE_BANDS[0]}
export SBLI=${SIDE_BANDS[1]}
export SBRI=${SIDE_BANDS[2]}
export SBRE=${SIDE_BANDS[3]}

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
                                            --slice-var-interval $SLICE_VAR_LO $SLICE_VAR_HI \
                                            --sidebands $SBLE $SBLI $SBRI $SBRE >& log_$INDEX.txt

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
