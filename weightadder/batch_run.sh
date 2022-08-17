#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/reco_efficiency_filler/install_nobrex
ANALYSISTREE_DIR=AnalysisTree_2/install_root6.20_cpp17_debian10_nobrex

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/include/AnalysisTree

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/weightadd

PDG=3122
# PDG=310
# PDG=3312

# BEAM_MOM=12
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1-100
# # EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.apr20.dcmqgsm.12agev.recpid.lightcuts1.3122and310.root
# EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.apr20.dcmqgsm.12agev.recpid.defaultcuts.3312and3334.root

# BEAM_MOM=12
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 21-60
# EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.$PDG.urqmd.12agev.defcuts.gen1.root

BEAM_MOM=3.3
SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56 # 1-60
EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.apr20.dcmqgsm.${BEAM_MOM}agev.recpid.lightcuts1.3122and310.root

SETUP_REC=recpid/lightcuts1/3122and310
# SETUP_REC=recpid/defaultcuts/3312and3334

EXE_DIR=$SOFT_DIR/bin
EXE=efficiency_filler

INPUT_DIR=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM/$SETUP_REC/$PDG
LOG_DIR=$OUTPUT_DIR/log
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

ls -d $INPUT_DIR/PFSimpleOutput.$INDEX.root > filelist_sec.list

./$EXE filelist_sec.list $EFFMAP_FILE $PDG/eff $PDG $BEAM_MOM >& log_$INDEX.txt

rm $EXE

mv fillerOut.root fillerOut.$INDEX.root

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