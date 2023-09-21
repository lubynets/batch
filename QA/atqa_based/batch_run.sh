#!/bin/bash

echo
echo "Bash script started"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
date

g++ --version
gcc --version
cc --version

# source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh
#
ATQA_DIR=AnalysisTreeQA
SOFT_DIR=/lustre/cbm/users/lubynets/soft/$ATQA_DIR/install
source ${SOFT_DIR}/bin/AnalysisTreeQAConfig.sh
#
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/lib
# export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTree
# export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/include/AnalysisTreeQA



echo
echo "Environment variables are set"
echo "LD_LIBRARY_PATH="$LD_LIBRARY_PATH
echo "ROOT_INCLUDE_PATH="$ROOT_INCLUDE_PATH
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=1

# REC_MODE=standard
# REC_MODE=v0default

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1 - 5000
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001 - 3000
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56 # 1 - 3000

PID=nopid
# PID=recpid
# PID=mcpid

# PDGS=3122and310
PDGS=3312and3334

# SETUP_REC=nopid/nocuts/invmasscut/3122
# SETUP_REC=recpid/nocuts/invmasscut/3122and310
SETUP_REC=$PID/defaultcuts/$PDGS

EXE_DIR=$SOFT_DIR/bin
# EXE=pt_eta
EXE=pfs_qa
# EXE=g4_proc_id

# INPUT_DIR=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/AT2
INPUT_DIR=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC
# INPUT_DIR=/lustre/cbm/users/lubynets/pidadd/outputs/$SETUP_SIM
OUTPUT_DIR=$PROJECT_DIR/outputs/$EXE/$SETUP_SIM/$SETUP_REC
# OUTPUT_DIR=$PROJECT_DIR/outputs/$EXE/sw
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

echo
echo "Exe done"
date

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
