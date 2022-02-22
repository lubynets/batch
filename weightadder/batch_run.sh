#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/reco_efficiency_filler/install_root6.20_cpp17_debian10

ANALYSISTREE_DIR=AnalysisTree_2/install_root6.20_cpp17_debian10

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/include/AnalysisTree

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/weightadd

# PDG=3122
# PDG=310
PDG=3312

# BEAM_MOM=12
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1-100
# EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.$PDG.dcm.12agev.defcuts.gen1.root

# BEAM_MOM=12
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 21-60
# EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.$PDG.urqmd.12agev.defcuts.gen1.root

BEAM_MOM=3.3
SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56 # 1-60
EFFMAP_FILE=$PROJECT_DIR/effmaps/effmap.$PDG.dcm.3.3agev.defcuts.gen1.root

SETUP_REC=mcpid/defaultcuts/$PDG

EXE_DIR=$SOFT_DIR/bin
EXE=main

FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/pfsimple/$SETUP_SIM/$SETUP_REC/1perfile
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM/$SETUP_REC
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

./$EXE $FILELIST_DIR/filelist.$INDEX.list $EFFMAP_FILE $PDG/eff $PDG $BEAM_MOM >& log_$INDEX.txt

rm $EXE

cd ..
mv $INDEX $OUTPUT_DIR

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date