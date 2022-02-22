#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

ATQA_DIR=AnalysisTreeQA_2
SOFT_DIR=/lustre/cbm/users/lubynets/soft/$ATQA_DIR/install_brex

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTreeQA

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

# PDG=3122
# PDG=310

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_apr20_target_25_mkm/TGeant4
# SETUP_SIM=apr21_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_target_25_mkm/TGeant4

SETUP_REC=standard/recpid/defaultcuts/3122and310

EXE_DIR=$SOFT_DIR/bin
EXE=pfs_qa

# FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/pidadd/$SETUP_SIM/50perfile
OUTPUT_DIR=$PROJECT_DIR/outputs/$EXE/$SETUP_SIM/$SETUP_REC
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

# ./$EXE $FILELIST_DIR/filelist.$INDEX.list >& log_$INDEX.txt

ls -d /lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC/PFSimpleOutput.$INDEX.root > filelist.list

./$EXE filelist.list >& log_$INDEX.txt

rm $EXE filelist.list

cd ..
mv $INDEX $OUTPUT_DIR

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date