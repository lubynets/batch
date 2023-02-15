#!/bin/bash

echo
echo "Bash script started"
date

g++ --version
gcc --version
cc --version

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh

ATQA_DIR=AnalysisTreeQA
SOFT_DIR=/lustre/cbm/users/lubynets/soft/$ATQA_DIR/install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTreeQA

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=1

# REC_MODE=standard
# REC_MODE=v0default

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1 - 5000
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001 - 3000
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56 # 1 - 3000

# SETUP_REC=recpid/$REC_MODE/defaultcuts/3312and3334

EXE_DIR=$SOFT_DIR/bin
EXE=pfs_qa

# INPUT_DIR=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/AT2
INPUT_DIR=/lustre/cbm/users/lubynets/pfsimple/outputs/sw
# OUTPUT_DIR=$PROJECT_DIR/outputs/$EXE/$SETUP_SIM
OUTPUT_DIR=$PROJECT_DIR/outputs/$EXE/sw
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

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
# ls -d $INPUT_DIR/$FILE_NUMBER.analysistree.root >> filelist.list
ls -d $INPUT_DIR/PFSimpleOutput.$FILE_NUMBER.root >> filelist.list
# ls -d $INPUT_DIR/pid.analysistree.$FILE_NUMBER.root >> filelist.list
done

./$EXE filelist.list >& log_$INDEX.txt

rm $EXE filelist.list
mv $EXE.root $EXE.$INDEX.root

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
