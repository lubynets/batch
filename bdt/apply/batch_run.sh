#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

export INDEX=${SLURM_ARRAY_TASK_ID}


MODEL_NAME=HL3_ctwise

# IO_PREFIX=data/lhc22.apass7/all/noConstr/$MODEL_NAME # 976
# IO_PREFIX=mc/lhc24e3/all/noConstr/$MODEL_NAME # 403

IO_PREFIX=HL/data/HF_LHC23_pass4_Thin_small_2P3PDstar/515291_allData # 1

TREES_DIR=plainer
# TREES_DIR=ali2atree

export INPUT_DIR=/lustre/alice/users/lubynets/$TREES_DIR/outputs/$IO_PREFIX
export MODEL_DIR=$PROJECT_DIR/outputs_train/$MODEL_NAME

OUTPUT_DIR=$PROJECT_DIR/outputs_apply/$IO_PREFIX/$MODEL_NAME
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

export CONFIG_DIR=$PROJECT_DIR/config
export MACRO_DIR=$PROJECT_DIR/macro

mkdir -p $WORK_DIR/$INDEX
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

SLICE_VAR_RANGES=('0.006' '0.0105' '0.015' '0.021' '0.027' '0.048')

for ((ISLICEVAR = 1; ISLICEVAR < ${#SLICE_VAR_RANGES[@]}; ISLICEVAR++)); do
export ISLICEVAR
export SLICE_VAR_LO=${SLICE_VAR_RANGES[$(($ISLICEVAR-1))]}
export SLICE_VAR_HI=${SLICE_VAR_RANGES[$ISLICEVAR]}

apptainer shell /lustre/alice/users/lubynets/singularities/bdt.sif << \EOF
source /usr/local/install/bin/thisroot.sh

python3 $MACRO_DIR/apply_BDT_to_data.py --config-file $CONFIG_DIR/config.train.yaml \
                                        --config-file-sel $CONFIG_DIR/config.train_selection.yaml \
                                        --input-file $INPUT_DIR/PlainTree.$INDEX.root \
                                        --tree-name pTree \
                                        --model-file $MODEL_DIR/model/$ISLICEVAR/BDTmodel_ct_0_0_v1.pkl \
                                        --output-directory $WORK_DIR/$INDEX \
                                        --slice-var-name fLiteCt \
                                        --slice-var-interval ${SLICE_VAR_LO} ${SLICE_VAR_HI} >& log_ct_${ISLICEVAR}.$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error
CP $MACRO_DIR apply_BDT_to_data.py $LOG_DIR/jobs
CP $CONFIG_DIR config.train.yaml $LOG_DIR/jobs
CP $CONFIG_DIR config.train_selection.yaml $LOG_DIR/jobs
mv appliedBdt.root appliedBdt.ct_${ISLICEVAR}.$INDEX.root
mkdir -p $OUTPUT_DIR/ct_${ISLICEVAR}
mv *root $OUTPUT_DIR/ct_${ISLICEVAR}
done

cd ..
rm -r $INDEX

if [ ! -f $WORK_DIR/env.txt ]; then
echo "$LOG_DIR" > $WORK_DIR/env.txt
fi

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
