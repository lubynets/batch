#!/bin/bash

echo
echo "Bash script started"
date

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh

PFSIMPLE_DIR=PFSimple/install

SOFT_DIR=/lustre/cbm/users/$USER/soft/$PFSIMPLE_DIR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/external/lib

# export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include
# export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTree
# export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/external/include
# export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/external/include/Vc

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=1

PROJECT_DIR=/lustre/cbm/users/$USER/pfsimple

PDGS=3122
# PDGS=3312

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56

INPUT_DIR=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM

SETUP_REC=mcpid/defaultcuts/$PDGS

EXE_DIR=$SOFT_DIR/bin
EXE=main2
# EXE=main
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM/$SETUP_REC
# OUTPUT_DIR=$PROJECT_DIR/outputs/orig
LOG_DIR=$OUTPUT_DIR/log
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/$EXE ./

if [ -f "filelist.list" ]
then
rm filelist.list
fi

for K in `seq 1 $FILES_PER_JOB`
do
FILE_NUMBER=$(($(($FILES_PER_JOB*$(($INDEX-1))))+$K))
ls -d $INPUT_DIR/AT2/$FILE_NUMBER.analysistree.root >> filelist.list
# ls -d $INPUT_DIR/pid.analysistree.$FILE_NUMBER.root >> filelist.list
done

./$EXE filelist.list >& log_${INDEX}.txt

rm $EXE
mv PFSimpleOutput.root PFSimpleOutput.$INDEX.root
mv PFSimplePlainTree.root PFSimplePlainTree.$INDEX.root

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
