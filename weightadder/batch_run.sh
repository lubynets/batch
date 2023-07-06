#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/reco_efficiency_filler/install
ANALYSISTREE_DIR=AnalysisTree/install_root6.24_master

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/include/AnalysisTree

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

CBM_FILES_PER_JOB=50

PROJECT_DIR=/lustre/cbm/users/lubynets/weightadd

# BEAM_MOM=12
# EVEGEN=dcmqgsm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${BEAM_MOM}agev/mbias/sis100_electron_target_25_mkm # 1-100

# BEAM_MOM=12
# EVEGEN=urqmd
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${BEAM_MOM}agev/mbias/sis100_electron_target_25_mkm # 21-60

BEAM_MOM=3.3
EVEGEN=dcmqgsm
SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${BEAM_MOM}agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56 # 1-60

# EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap_pt_y_C.${EVEGEN}.${BEAM_MOM}agev.3122and310.root
# EFFMAP_FILE=$PROJECT_DIR/effmaps/th2.${EVEGEN}.${BEAM_MOM}agev.3122and310.oc1.root
EFFMAP_FILE=$PROJECT_DIR/effmaps/th2.${EVEGEN}.${BEAM_MOM}agev.3312and3334.root

# SETUP_REC=recpid/lightcuts1/3122and310
# SETUP_REC=recpid/optimcuts1/3122and310
SETUP_REC=recpid/defaultcuts/3312and3334

EXE_DIR=$SOFT_DIR/bin
EXE=efficiency_filler
# EXE=rapidity_filler

PFSIMPLE_DIR=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC
PID_DIR=/lustre/cbm/users/lubynets/pidadd/outputs/$SETUP_SIM
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM/$SETUP_REC
# OUTPUT_DIR=${PID_DIR}_extra
LOG_DIR=$OUTPUT_DIR/log
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

if [ -f "filelist_cbm.list" ]
then
rm filelist_cbm.list
fi

if [ -f "filelist_pfs.list" ]
then
rm filelist_pfs.list
fi

ls -d $PFSIMPLE_DIR/PFSimpleOutput.$INDEX.root > filelist_pfs.list

for K in `seq 1 $CBM_FILES_PER_JOB`
do
FILE_NUMBER=$(($(($CBM_FILES_PER_JOB*$(($INDEX-1))))+$K))
ls -d $PID_DIR/pid.analysistree.$FILE_NUMBER.root >> filelist_cbm.list
done

./$EXE filelist_cbm.list filelist_pfs.list $EFFMAP_FILE $BEAM_MOM >& log_$INDEX.txt
# ./$EXE filelist_cbm.list >& log_$INDEX.txt

rm $EXE

mv fillerOut.root fillerOut.$INDEX.root
# mv pid.analysistree.root pid.analysistree.$INDEX.root

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
