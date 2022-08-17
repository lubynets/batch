#!/bin/bash

echo
echo "Bash script started"
date

g++ --version
gcc --version
cc --version

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh
ANALYSISTREE_DIR=AnalysisTree_2/install_root6.20_cpp17_debian10_nobrex

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/QnTools/install/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/QnTools/install/include

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=50

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

BEAM_MOM=12

PDG=3122
# PDG=310

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1 - 5000
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001 - 3000
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56 # 1 - 3000

SETUP_REC=recpid/lightcuts1/3122and310
# SETUP_REC=recpid/defaultcuts/3312and3334

MACRO_DIR=$PROJECT_DIR/macro

INPUT_DIR_SIM=/lustre/cbm/users/lubynets/centradd/outputs/$SETUP_SIM
INPUT_DIR_REC=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC

# MACRO=massDC
MACRO=cplxmap_pt_y_C
# MACRO=multiplicity_qa
# MACRO=m2_pq_vtx

OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

if [ -f "filelist_sim.list" ]
then
rm filelist_sim.list
fi

if [ -f "filelist_rec.list" ]
then
rm filelist_rec.list
fi

for K in `seq 1 $FILES_PER_JOB`
do
FILE_NUMBER=$(($(($FILES_PER_JOB*$(($INDEX-1))))+$K))
ls -d $INPUT_DIR_SIM/centrality.analysistree.$FILE_NUMBER.root >> filelist_sim.list
done

ls -d $INPUT_DIR_REC/PFSimpleOutput.$INDEX.root >> filelist_rec.list

# root -l -b -q "${MACRO}.C(\"$FILELIST_DIR/filelist.$INDEX.list\", \"filelist_sec.list\", $PDG)" >& log_${INDEX}.txt
root -l -b -q "${MACRO}.C(\"filelist_sim.list\", \"filelist_rec.list\", $BEAM_MOM)" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}.C({\"$FILELIST_DIR/filelist.$INDEX.list\"})" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}.C(\"/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/AT1/$INDEX.analysistree.root\")" >& log_${INDEX}.txt
                    
rm $MACRO.C

mv $MACRO.root $MACRO.$INDEX.root

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