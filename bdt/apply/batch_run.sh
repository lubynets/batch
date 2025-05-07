#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

export INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/bdt

IO_PREFIX=data/lhc22.apass7/all/noConstr/noSel/sidebands # 976
# IO_PREFIX=mc/lhc24e3/sig_bgsup100/noConstr # 403

export INPUT_DIR=/lustre/alice/users/lubynets/plainer/outputs/$IO_PREFIX
export MODEL_DIR=/lustre/alice/users/lubynets/bdt/outputs_train/thirdTry

export WORK_DIR=$PROJECT_DIR/workdir
OUTPUT_DIR=$PROJECT_DIR/outputs_apply/$IO_PREFIX
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

export CONFIG_DIR=$PROJECT_DIR/config
export MACRO_DIR=$PROJECT_DIR/macro

mkdir -p $WORK_DIR/$INDEX
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

PT_RANGES=('0' '2' '5' '8' '12' '20')

for ((IPT = 1; IPT < ${#PT_RANGES[@]}; IPT++)); do
export IPT
export PT_LO=${PT_RANGES[$(($IPT-1))]}
export PT_HI=${PT_RANGES[$IPT]}

apptainer shell /lustre/alice/users/lubynets/singularities/bdt.sif << \EOF
source /usr/local/install/bin/thisroot.sh

python3 $MACRO_DIR/apply_BDT_to_data.py --config-file-sel $CONFIG_DIR/config.train_selection.yaml \
                                        --input-file $INPUT_DIR/PlainTree.$INDEX.root \
                                        --tree-name pTree \
                                        --model-file $MODEL_DIR/model/$IPT/BDTmodel_pT_${PT_LO}_${PT_HI}_v1.pkl \
                                        --output-directory $WORK_DIR/$INDEX \
                                        --pT-interval ${PT_LO} ${PT_HI} >& log_pt_${IPT}.$INDEX.txt

EOF
# EOF to trigger the end of the singularity command

mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error
mv appliedBdt.root appliedBdt.pt_${IPT}.$INDEX.root
mkdir -p $OUTPUT_DIR/pt_${IPT}
mv *root $OUTPUT_DIR/pt_${IPT}
done

cd ..
rm -r $INDEX

if [ ! -f $WORK_DIR/env.txt ]; then
echo "$LOG_DIR" > $WORK_DIR/env.txt
fi

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
