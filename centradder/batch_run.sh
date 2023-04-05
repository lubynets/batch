#!/bin/bash

echo
echo "Bash script started"
date

echo
g++ --version
gcc --version
cc --version

SOFT_DIR=/lustre/cbm/users/lubynets/soft/Centrality/install
source ${SOFT_DIR}/bin/CentralityConfig.sh

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/centradd

# PBEAM=12
PBEAM=3.3

# EVEGEN=urqmd
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm

EVEGEN=dcmqgsm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm
SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56

EXE_DIR=$SOFT_DIR/bin
EXE=fill_centrality
EXE_STS=fill_centrality_sts
EXE_IMPACTPAR=fill_centrality_b

OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP_SIM/
LOG_DIR=$OUTPUT_DIR/logs
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/${EXE}* ./

CENTR_FILE_STS=${PROJECT_DIR}/getters/centr_getter.sts_mult.${EVEGEN}.${PBEAM}agev.root
CENTR_FILE_IMPACTPAR=${PROJECT_DIR}/getters/centr_getter.impactpar.${EVEGEN}.${PBEAM}agev.root

ls -d /lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/AT2/$INDEX.analysistree.root > filelist.list
./$EXE_STS filelist.list $CENTR_FILE_STS >& log_sts_$INDEX.txt
mv centrality.analysistree.root intermediate.root
rm filelist.list
ls -d intermediate.root > filelist.list
./$EXE_IMPACTPAR filelist.list $CENTR_FILE_IMPACTPAR >& log_b_$INDEX.txt
rm $EXE_STS $EXE_IMPACTPAR intermediate.root filelist.list

# ls -d $PROJECT_DIR/outputs/${SETUP_SIM}_old/$INDEX/centrality.analysistree.$INDEX.root > filelist.list
# ./$EXE filelist.list >& log_$INDEX.txt
# rm $EXE filelist.list

mv centrality.analysistree.root centrality.analysistree.$INDEX.root
mv *root $OUTPUT_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date
