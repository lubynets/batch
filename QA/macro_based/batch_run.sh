#!/bin/bash

echo
echo "Bash script started"
date

g++ --version
gcc --version
cc --version

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh
ANALYSISTREE_DIR=AnalysisTree_2/install_root6.20_cpp17_debian10_brex

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/include/AnalysisTree

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

BEAM_MOM=12

PDG=3122
# PDG=310

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56

SETUP_REC=nopid/defaultcuts/3122and310

MACRO_DIR=$PROJECT_DIR/macro
MACRO=tof_purity_sgnl_bckgr

# FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/pfsimple/$SETUP_SIM/$SETUP_REC/1perfile
# OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM/

# FILELIST_DIR_STD=/lustre/cbm/users/lubynets/filelists/pidadd/$SETUP_SIM/standard/50perfile
FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/pidadd/$SETUP_SIM/decay$PDG/50perfile


OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM/$SETUP_REC/$PDG
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

ls -d /lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC/$INDEX/PFSimpleOutput.$INDEX.root > filelist_sec.list

root -l -b -q "${MACRO}.C(\"$FILELIST_DIR/filelist.$INDEX.list\", \"filelist_sec.list\", $PDG)" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}.C(\"$FILELIST_DIR/filelist.$INDEX.list\", \"filelist_sec.list\", $PDG)" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}.C({\"$FILELIST_DIR/filelist.$INDEX.list\"})" >& log_${INDEX}.txt
                    
rm $MACRO.C

mv $MACRO $MACRO.$INDEX.root

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