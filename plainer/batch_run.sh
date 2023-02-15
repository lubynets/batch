#!/bin/bash

echo
echo "Bash script started"
date

ROOT_VERSION=install_6.24_cpp17_debian10
ANALYSISTREE_VERSION=install_root6.24_master
ATPLAINER_VERSION=install_master
# ATPLAINER_VERSION=install_impactpar

SOFT_DIR=/lustre/cbm/users/lubynets/soft

ANALYSISTREE_INSTALL=$SOFT_DIR/AnalysisTree/$ANALYSISTREE_VERSION
ATPLAINER_INSTALL=$SOFT_DIR/at_tree_plainer/$ATPLAINER_VERSION

source $SOFT_DIR/root-6/$ROOT_VERSION/bin/thisroot.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ANALYSISTREE_INSTALL/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ATPLAINER_INSTALL/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$ANALYSISTREE_INSTALL/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$ATPLAINER_INSTALL/include


INDEX=${SLURM_ARRAY_TASK_ID}

CBM_FILES_PER_JOB=1

PROJECT_DIR=/lustre/cbm/users/$USER/attreeplainer

PDGS=3312

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
SETUP_REC=nopid/qc1_all/$PDGS

EXE_DIR=$ATPLAINER_INSTALL/bin
EXE=main
OUTPUT_DIR=$PROJECT_DIR/outputs/$SETUP_SIM/${SETUP_REC}
LOG_DIR=$OUTPUT_DIR/log
WORK_DIR=$PROJECT_DIR/workdir

INPUT_CBM=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/AT2
INPUT_PFS=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC

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

for K in `seq 1 $CBM_FILES_PER_JOB`
do
FILE_NUMBER=$(($(($CBM_FILES_PER_JOB*$(($INDEX-1))))+$K))
ls -d $INPUT_CBM/$FILE_NUMBER.analysistree.root >> filelist_cbm.list
done

ls -d $INPUT_PFS/PFSimpleOutput.$INDEX.root >> filelist_pfs.list

./$EXE filelist_cbm.list filelist_pfs.list >& log_${INDEX}.txt

rm $EXE intermediate_tree.root filelist.txt
mv analysis_plain_ttree.root analysis_plain_ttree.$INDEX.root

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
