#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

PFSIMPLE_DIR=PFSimple_NEW/install_root6.20_cpp17_debian10_brex
# PFSIMPLE_DIR=PFSimple_NEW/install_cascade_root6.20_cpp17_debian10

ANALYSISTREE_DIR=AnalysisTree_2/install_root6.20_cpp17_debian10_brex

SOFT_DIR=/lustre/cbm/users/$USER/soft/$PFSIMPLE_DIR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/external/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/$USER/soft/$ANALYSISTREE_DIR/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/external/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/$USER/soft/$ANALYSISTREE_DIR/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/$USER/pfsimple

# PDG=3122
# PDG=310

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56

SETUP_SIM=$SETUP_SIM/standard

SETUP_REC=recpid/defaultcuts/3122and310

EXE_DIR=$SOFT_DIR/bin
EXE=main2
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM/$SETUP_REC
LOG_DIR=$OUTPUT_DIR/log
WORK_DIR=$PROJECT_DIR/workdir
FILELIST_DIR=/lustre/cbm/users/$USER/filelists/pidadd/$SETUP_SIM/50perfile

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

./$EXE $FILELIST_DIR/filelist.$INDEX.list >& log_${INDEX}.txt

rm $EXE
mv PFSimpleOutput.root PFSimpleOutput.$INDEX.root

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
